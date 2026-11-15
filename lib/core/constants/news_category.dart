import 'package:flutter/material.dart';

/// NuNews - News Category Definition
class NewsCategory {
  const NewsCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
  });

  final String id;
  final String name;
  final String slug;
  final IconData icon;
}

const List<NewsCategory> kNewsCategories = [
  NewsCategory(
    id: 'semua',
    name: 'Semua',
    slug: 'semua',
    icon: Icons.auto_awesome_rounded,
  ),
  NewsCategory(
    id: 'nasional',
    name: 'Nasional',
    slug: 'nasional',
    icon: Icons.flag_rounded,
  ),
  NewsCategory(
    id: 'internasional',
    name: 'Internasional',
    slug: 'internasional',
    icon: Icons.public_rounded,
  ),
  NewsCategory(
    id: 'ekonomi',
    name: 'Ekonomi',
    slug: 'ekonomi',
    icon: Icons.trending_up_rounded,
  ),
  NewsCategory(
    id: 'olahraga',
    name: 'Olahraga',
    slug: 'olahraga',
    icon: Icons.emoji_events_rounded,
  ),
  NewsCategory(
    id: 'teknologi',
    name: 'Teknologi',
    slug: 'teknologi',
    icon: Icons.memory_rounded,
  ),
  NewsCategory(
    id: 'hiburan',
    name: 'Hiburan',
    slug: 'hiburan',
    icon: Icons.movie_rounded,
  ),
  NewsCategory(
    id: 'gaya-hidup',
    name: 'Gaya Hidup',
    slug: 'gaya-hidup',
    icon: Icons.coffee_rounded,
  ),
];
