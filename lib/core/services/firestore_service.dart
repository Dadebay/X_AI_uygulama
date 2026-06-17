import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:atlas/models/tweet_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._();
  FirestoreService._();
  factory FirestoreService() => _instance;

  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    final snap = await _db.collection(collection).doc(docId).get();
    return snap.exists ? snap.data() : null;
  }

  /// Firestore `teams` koleksiyonundan takımları çeker.
  /// Her döküman yapısı:
  /// { id, name, shortName, logoUrl, followers, league, colors: ['#RRGGBB', ...] }
  Future<List<TeamModel>> getTeams() async {
    final snap = await _db
        .collection('teams')
        .orderBy('order')
        .get();
    return snap.docs.map((doc) {
      final d = doc.data();
      final rawColors = (d['colors'] as List<dynamic>?) ?? [];
      final colors = rawColors
          .map((c) => _hexToColor(c.toString()))
          .whereType<Color>()
          .toList();
      return TeamModel(
        id: doc.id,
        name: d['name']?.toString() ?? '',
        shortName: d['shortName']?.toString() ?? '',
        logoUrl: d['logoUrl']?.toString() ?? '',
        followers: (d['followers'] as num?)?.toInt() ?? 0,
        league: d['league']?.toString() ?? '',
        colors: colors,
      );
    }).toList();
  }

  Color? _hexToColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return null;
    }
  }
}
