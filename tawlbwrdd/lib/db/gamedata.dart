import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tawlbwrdd/model/game.dart';
import 'package:tawlbwrdd/model/fuseduserprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

final GoogleSignIn _googleSignIn = new GoogleSignIn();

///
/// Keeps track of the games and the change subscription.
///
class DbData<T> {
  final T games;
  final Stream<T> stream;
  DbData({this.games, this.stream});
}

///
/// Specialization to deal with game lists.
///
class GameListSetup extends DbData<List<Game>> {
  GameListSetup(List<Game> g, Stream<List<Game>> str)
      : super(games: g, stream: str);
}

///
/// Specialization to handle single games.
///
class SingleGameSetup extends DbData<Game> {
  SingleGameSetup(Game g, Stream<Game> str) : super(games: g, stream: str);
}

///
/// Connection to the firebase data system.
///
class GameData {
  bool _creating = false;
  FusedUserProfile currentProfile;
  FirebaseUser currentFirebaseUser;
  Stream<FusedUserProfile> onProfileChanged;
  final StreamController<FusedUserProfile> _profileChangedController =
      StreamController<FusedUserProfile>();

  GameData() {
    onProfileChanged = _profileChangedController.stream.asBroadcastStream();
    FirebaseAuth.instance.onAuthStateChanged.listen((FirebaseUser user) {
      _onAuthChanged(user);
    });
  }

  ///
  /// Signs out of the firebase system.
  ///
  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  ///
  /// Updates the specific game into firebase.
  ///
  Future<void> updateGame(Game game) async {
    return Firestore.instance
        .collection("Games")
        .document(game.uid)
        .updateData(game.toJSON());
  }

  ///
  /// Add the game into firebase.
  ///
  Future<Game> addGame(Game game) async {
    print('bing ${game.toJSON()}');
    DocumentReference ref =
        await Firestore.instance.collection("Games").add(game.toJSON());

    return new Game.copyWith(ref.documentID, game);
  }

  ///
  /// Get the current user out of firebase and not the cached
  /// version of it.
  ///
  Future<void> currentUserAsync() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print('Loaded stuff $user');
    if (user != null) {
      FusedUserProfile profile = await getProfile(user.uid);
      currentFirebaseUser = user;
      currentProfile = profile;
    }
    print('profile $currentFirebaseUser');
  }

  ///
  /// Gets all the currently open games associated with this user.
  ///  This includes games which no one else has joined yet.
  ///
  Future<GameListSetup> getGames(String userId) async {
    // Get all the games for me.
    Query query = Firestore.instance
        .collection("Games")
        .where(Game.PLAYER + "." + userId + "." + Game.ADDED, isEqualTo: true);
    QuerySnapshot snap = await query.getDocuments();
    List<Game> ret = [];
    print('Loaded data ${snap.documents.length}');
    for (DocumentSnapshot change in snap.documents) {
      print('${change.data}');

      ret.add(new Game.fromJSON(change.documentID, change.data));
    }
    return new GameListSetup(
        ret, query.snapshots().transform(new _GameTransformer()));
  }

  ///
  /// Current games that need players.
  ///
  Future<GameListSetup> getGamesNeedingPlayers() async {
    // Get all the games for me.
    Query query = Firestore.instance
        .collection("Games")
        .where(Game.STATUS, isEqualTo: GameStatus.WaitingForPlayer.toString());
    QuerySnapshot snap = await query.getDocuments();
    List<Game> ret = [];
    for (DocumentSnapshot change in snap.documents) {
      Game g = new Game.fromJSON(change.documentID, change.data);
      if (g.playerUidDefender == currentFirebaseUser.uid ||
          g.playerUidAttacker == currentFirebaseUser.uid) {
        continue;
      }
      ret.add(g);
    }
    return new GameListSetup(
        ret,
        query.snapshots().transform(
            new _GameTransformer(filterUid: currentFirebaseUser.uid)));
  }

  ///
  /// A string that shows the attacker vs defender to put in
  /// the ux.
  ///
  Future<String> getGameVs(Game game) async {
    FusedUserProfile attacker;
    if (game.playerUidAttacker != null) {
      attacker = await getProfile(game.playerUidAttacker);
    }
    FusedUserProfile defender;
    if (game.playerUidDefender != null) {
      defender = await getProfile(game.playerUidDefender);
    }
    String attackerStr;
    if (attacker == null) {
      attackerStr = "TBD";
    } else {
      attackerStr = attacker.displayName;
    }
    String defenderStr;
    if (defender == null) {
      defenderStr = "TBD";
    } else {
      defenderStr = defender.displayName;
    }
    return "$attackerStr vs $defenderStr";
  }

  ///
  /// Get the data for a specific game.
  ///
  Future<SingleGameSetup> getGame(String gameId) async {
    DocumentSnapshot snap =
        await Firestore.instance.collection("Games").document(gameId).get();

    if (snap.exists) {
      return new SingleGameSetup(new Game.fromJSON(snap.documentID, snap.data),
          snap.reference.snapshots().transform(new _SingleGameTransformer()));
    }
    return new SingleGameSetup(null,
        snap.reference.snapshots().transform(new _SingleGameTransformer()));
  }

  ///
  /// Get the profile details for a specific user.
  ///
  Future<FusedUserProfile> getProfile(String uid) async {
    if (uid == null) {
      return new FusedUserProfile(uid, displayName: "TBD");
    }
    DocumentSnapshot doc =
        await Firestore.instance.collection("Users").document(uid).get();
    if (doc.exists) {
      return new FusedUserProfile.fromJSON(doc.documentID, doc.data);
    }
    return new FusedUserProfile(uid, displayName: "Bad user");
  }

  ///
  /// Load the basic user details from fireastore.
  ///
  Future<FusedUserProfile> loadUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      FusedUserProfile profile = await getProfile(user.uid);
      currentProfile = profile;
    }
    currentFirebaseUser = user;
  }

  ///
  /// Sign in anonymously (default experience).
  ///
  Future<FusedUserProfile> signInAnonymously(String name) async {
    _creating = true;
    try {
      print('1');
      FirebaseUser user = await FirebaseAuth.instance.signInAnonymously();
      print('2');
      FusedUserProfile profile =
          new FusedUserProfile(user.uid, displayName: name);
      print('3');
      currentFirebaseUser = user;
      currentProfile = profile;
      print('4');
      await Firestore.instance
          .collection("Users")
          .document(user.uid)
          .setData(profile.toJSON());
      print('5');
      _profileChangedController.add(currentProfile);
      print('6');
    } finally {
      _creating = false;
    }
    return currentProfile;
  }

  ///
  /// Sign  in with google.  This will also convert the anonymous games to the
  /// new user id associated with the google account.
  ///
  Future<FusedUserProfile> signInWithGoogle() async {
    _creating = true;
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final FirebaseUser user = await FirebaseAuth.instance.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      FusedUserProfile profile =
          new FusedUserProfile(user.uid, displayName: user.displayName);
      await Firestore.instance
          .collection("Users")
          .document(user.uid)
          .updateData(profile.toJSON());
      currentProfile = profile;
      _profileChangedController.add(currentProfile);
      return profile;
    } finally {
      _creating = false;
    }
  }

  void _onAuthChanged(FirebaseUser user) async {
    if (user == null) {
      // Logged out.
      _profileChangedController.add(null);
    } else {
      if (!_creating) {
        FusedUserProfile profile = await getProfile(user.uid);
        if (profile == null) {
          profile = new FusedUserProfile(user.uid, displayName: 'Unknown');
          await Firestore.instance
              .collection("Users")
              .document(user.uid)
              .updateData(profile.toJSON());
          currentProfile = profile;
          currentFirebaseUser = user;
          _profileChangedController.add(currentProfile);
        }
      }
    }
  }

  ///
  /// Set the notification token for the current user.
  ///
  Future<void> setNotificationToken(String token) async {
    Map<String, bool> data = <String, bool>{};
    String key = "${FusedUserProfile.TOKENS}.$token";

    data[key] = true;
    return Firestore.instance
        .collection("Users")
        .document(currentFirebaseUser.uid)
        .updateData(data);
  }
}

///
/// Transforms a document snapshot into a list of games.
///
class _GameTransformer
    extends StreamTransformerBase<QuerySnapshot, List<Game>> {
  StreamController<List<Game>> _controller;
  final String filterUid;

  StreamSubscription _subscription;

  // Original Stream
  Stream<QuerySnapshot> _stream;

  _GameTransformer({this.filterUid}) {
    _controller = new StreamController<List<Game>>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  ///
  /// Transformation
  ///
  void onData(QuerySnapshot snap) {
    List<Game> ret = [];
    for (DocumentSnapshot change in snap.documents) {
      Game g = new Game.fromJSON(change.documentID, change.data);
      if (g.playerUidDefender == filterUid ||
          g.playerUidAttacker == filterUid) {
        continue;
      }
      ret.add(g);
    }

    _controller.add(ret);
  }

  ///
  /// Bind
  ///
  Stream<List<Game>> bind(Stream<QuerySnapshot> stream) {
    this._stream = stream;
    return _controller.stream;
  }
}

///
/// Transforms a document snapshot into a singla game.
///
class _SingleGameTransformer
    extends StreamTransformerBase<DocumentSnapshot, Game> {
  StreamController<Game> _controller;

  StreamSubscription _subscription;

  // Original Stream
  Stream<DocumentSnapshot> _stream;

  _SingleGameTransformer() {
    _controller = new StreamController<Game>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  ///
  /// Transformation
  ///
  void onData(DocumentSnapshot snap) {
    _controller.add(new Game.fromJSON(snap.documentID, snap.data));
  }

  ///
  /// Bind
  ///
  Stream<Game> bind(Stream<DocumentSnapshot> stream) {
    this._stream = stream;
    return _controller.stream;
  }
}
