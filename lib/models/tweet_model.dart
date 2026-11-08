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

  const TrendTopic(
      {required this.rank, required this.name, required this.postCount});
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
