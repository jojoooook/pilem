import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:pilem/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Movie> searchResults = [];
  String query = '';
  final ApiService apiService = ApiService();
  List<int> favoriteMovieIds = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteMovies();
  }

  Future<void> loadFavoriteMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites');
    if (favorites != null) {
      setState(() {
        favoriteMovieIds = favorites.map((item) => Movie.fromJson(json.decode(item)).id).toList();
      });
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    if (favoriteMovieIds.contains(movie.id)) {
      favorites.removeWhere((item) => Movie.fromJson(json.decode(item)).id == movie.id);
      setState(() {
        favoriteMovieIds.remove(movie.id);
      });
    } else {
      favorites.add(json.encode(movie.toJson()));
      setState(() {
        favoriteMovieIds.add(movie.id);
      });
    }
    await prefs.setStringList('favorites', favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
                searchMovies(query);
              },
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: searchResults.isEmpty
          ? const Center(child: Text('No results found.'))
          : ListView.separated(
        itemCount: searchResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        padding: const EdgeInsets.all(5.0),
        itemBuilder: (context, index) {
          final movie = searchResults[index];
          return ListTile(
            leading: movie.posterPath.isNotEmpty
                ? Image.network(
              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
              width: 50,
              fit: BoxFit.cover,
            )
                : const SizedBox(width: 50),
            title: Text(
              movie.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(
                favoriteMovieIds.contains(movie.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoriteMovieIds.contains(movie.id) ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                toggleFavorite(movie);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(movie: movie),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> searchMovies(String query) async {
    if (query.isNotEmpty) {
      final response = await apiService.searchMovies(query);
      if (response != null) {
        setState(() {
          searchResults = response
              .map((json) => Movie.fromJson(json))
              .where((movie) => movie.title.toLowerCase().contains(query.toLowerCase()))
              .take(5)
              .toList();
        });
      } else {
        setState(() {
          searchResults = [];
        });
      }
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }
}