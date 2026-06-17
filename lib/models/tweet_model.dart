import 'package:flutter/material.dart';

class TweetMedia {
  final String url; // gösterilecek görsel (foto ya da video thumbnail)
  final bool isVideo;

  const TweetMedia({required this.url, this.isVideo = false});
}

class TweetModel {
  final String id;
  final String username;
  final String handle;
  final String avatarUrl;
  final String content;
  final String timeAgo;
  final int replies;
  final int retweets;
  final int likes;
  final String? tweetUrl;
  final bool isVerified;
  final List<String> tags;
  final List<TweetMedia> media;

  const TweetModel({
    required this.id,
    required this.username,
    required this.handle,
    required this.content,
    required this.timeAgo,
    this.avatarUrl = '',
    this.replies = 0,
    this.retweets = 0,
    this.likes = 0,
    this.tweetUrl,
    this.isVerified = false,
    this.tags = const [],
    this.media = const [],
  });
}

class TrendTopic {
  final int rank;
  final String name;
  final String postCount;

  const TrendTopic({required this.rank, required this.name, required this.postCount});
}

class TeamModel {
  final String id;
  final String name;
  final String shortName;
  final String logoUrl;
  final String logoAsset;
  final int followers;
  final String league;
  final List<Color> colors;

  const TeamModel({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl = '',
    this.logoAsset = '',
    this.followers = 0,
    this.league = '',
    this.colors = const [],
  });
}

// ── Mock data ──

class MockData {
  static const List<TweetModel> homeFeed = [
    TweetModel(
      id: '1',
      username: 'Fabrizio Romano',
      handle: 'FabrizioRomano',
      content: 'Understand Victor Osimhen is open to joining Galatasaray this summer! 🔴🟡 Discussions ongoing between clubs. #GalatasarayOsimhen',
      timeAgo: '1g',
      replies: 1200,
      retweets: 2400,
      likes: 18000,
      isVerified: true,
      tags: ['GS', 'Transfer'],
      tweetUrl: 'https://x.com',
    ),
    TweetModel(
      id: '2',
      username: 'Yağız Sabuncuoğlu',
      handle: 'yagiz_sabuncuoglu',
      content: 'Galatasaray, Osimhen için Napoli ile 50M€ bonservis konusunda görüşüyor.',
      timeAgo: '2g',
      replies: 230,
      retweets: 510,
      likes: 4100,
      isVerified: true,
      tags: ['GS', 'Transfer'],
      tweetUrl: 'https://x.com',
    ),
    TweetModel(
      id: '3',
      username: 'Erden Timur',
      handle: 'ErdenTimur1905',
      content: 'Hedefiniz büyük. Takımımız ve camiamız için çalışmaya devam! 💛❤️',
      timeAgo: '1g',
      replies: 1100,
      retweets: 2300,
      likes: 19000,
      isVerified: true,
      tags: ['GS'],
      tweetUrl: 'https://x.com',
    ),
    TweetModel(
      id: '4',
      username: 'Ali Naci Küçük',
      handle: 'AliNaciKucuk',
      content: 'Osimhen için görüşmeler sürüyor. Ciddi ilerleme var. ⚡',
      timeAgo: '3g',
      replies: 310,
      retweets: 620,
      likes: 3200,
      isVerified: false,
      tags: ['GS', 'Transfer'],
      tweetUrl: 'https://x.com',
    ),
    TweetModel(
      id: '5',
      username: 'Troll Football',
      handle: 'TrollFootball',
      content: 'This team never stops entertaining 🔥🔥',
      timeAgo: '8g',
      replies: 540,
      retweets: 1200,
      likes: 8700,
      isVerified: false,
      tags: ['GS'],
      tweetUrl: 'https://x.com',
    ),
  ];

  static const List<TrendTopic> trendTopics = [
    TrendTopic(rank: 1, name: 'Osimhen', postCount: '124K gönderi'),
    TrendTopic(rank: 2, name: 'Galatasaray', postCount: '98K gönderi'),
    TrendTopic(rank: 3, name: 'Şampiyonlar Ligi', postCount: '78K gönderi'),
    TrendTopic(rank: 4, name: 'Mourinho', postCount: '61K gönderi'),
    TrendTopic(rank: 5, name: 'Fenerbahçe', postCount: '55K gönderi'),
    TrendTopic(rank: 6, name: 'Beşiktaş', postCount: '43K gönderi'),
  ];

  static const List<TeamModel> teams = [
    TeamModel(
        id: 'gs',
        name: 'Galatasaray',
        shortName: 'GS',
        followers: 142000,
        league: 'Süper Lig',
        logoAsset: 'assets/images/Galatasaray_SK_football_logo.png',
        colors: [Color(0xFFE8231A), Color(0xFFFFD700)]),
    TeamModel(id: 'fb', name: 'Fenerbahçe', shortName: 'FB', followers: 138000, league: 'Süper Lig', logoAsset: 'assets/images/Fenerbah.png', colors: [Color(0xFF003087), Color(0xFFFFD700)]),
    TeamModel(id: 'bjk', name: 'Beşiktaş', shortName: 'BJK', followers: 112000, league: 'Süper Lig', logoAsset: 'assets/images/kartal.png', colors: [Color(0xFF1A1A1A), Color(0xFFFFFFFF)]),
    TeamModel(id: 'ts', name: 'Trabzonspor', shortName: 'TS', followers: 84000, league: 'Süper Lig', colors: [Color(0xFF8B0000), Color(0xFF001489)]),
    TeamModel(id: 'ucl', name: 'Şampiyonlar Ligi', shortName: 'UCL', followers: 210000, league: 'UEFA', colors: [Color(0xFF1D9BF0), Color(0xFF000000)]),
    TeamModel(id: 'el', name: 'Avrupa Ligi', shortName: 'UEL', followers: 95000, league: 'UEFA', colors: [Color(0xFFFF6600), Color(0xFF000000)]),
  ];

  static const aiSummary = 'Bugün Galatasaray ile ilgili en çok konuşulan konu Osimhen transferi oldu. '
      'Taraftarların %82\'si transferin olumlu sonuçlanacağını düşünüyor. '
      'İkinci gündem, yeni sezon formaları ve teknik direktör planlamasıdır.';
}
