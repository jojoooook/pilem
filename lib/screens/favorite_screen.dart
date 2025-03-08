import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Movie> favoriteMovies = [];

  Future<void> _loadFavoriteMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? movies = prefs.getStringList('favorites');
    if (movies != null) {
      setState(() {
        favoriteMovies = movies.map((movie) => Movie.fromJson(jsonDecode(movie))).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Movies'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
              child: Center(
                child: Text(
                  ' Your Favorite Movies',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Grid film
            Expanded(
              child: favoriteMovies.isEmpty
                  ? const Center(
                child: Text(
                  'No favorite movies found',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Jumlah kolom dalam grid
                  crossAxisSpacing: 8.0, // Jarak horizontal antar kotak
                  mainAxisSpacing: 8.0, // Jarak vertikal antar kotak
                  childAspectRatio: 0.55, // Rasio kotak untuk gambar + teks
                ),
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(movie: movie),
                        ),
                      );
                      _loadFavoriteMovies(); // Reload favorites after returning
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Gambar Film dengan ukuran tetap menggunakan AspectRatio
                          AspectRatio(
                            aspectRatio: 3 / 4, // Rasio gambar 3:4
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                fit: BoxFit.cover, // Gambar memenuhi area
                              ),
                            ),
                          ),
                          // Nama Film dengan batas 2 baris
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              movie.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}