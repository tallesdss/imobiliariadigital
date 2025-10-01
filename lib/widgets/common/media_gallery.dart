import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

enum MediaType { photo, video }

class MediaItem {
  final String url;
  final MediaType type;
  final String? thumbnail;

  MediaItem({required this.url, required this.type, this.thumbnail});
}

class MediaGallery extends StatefulWidget {
  final List<String> photos;
  final List<String> videos;

  const MediaGallery({super.key, required this.photos, required this.videos});

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.videos.isNotEmpty ? 2 : 1,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty && widget.videos.isEmpty) {
      return Container(
        height: 300,
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(
            Icons.home_work_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    if (widget.videos.isEmpty) {
      return _buildPhotoCarousel();
    }

    return Column(
      children: [
        Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library, size: 20),
                    const SizedBox(width: 8),
                    Text('Fotos (${widget.photos.length})'),
                  ],
                ),
              ),
              if (widget.videos.isNotEmpty)
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle, size: 20),
                      const SizedBox(width: 8),
                      Text('Vídeos (${widget.videos.length})'),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPhotoCarousel(),
              if (widget.videos.isNotEmpty) _buildVideoPlaylist(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCarousel() {
    if (widget.photos.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
              SizedBox(height: 8),
              Text(
                'Nenhuma foto disponível',
                style: TextStyle(color: AppColors.textHint),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.photos.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.network(
              widget.photos[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                );
              },
            );
          },
        ),
        if (widget.photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        // Contador de fotos
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${widget.photos.length}',
              style: AppTypography.labelSmall.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlaylist() {
    if (widget.videos.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
              SizedBox(height: 8),
              Text(
                'Nenhum vídeo disponível',
                style: TextStyle(color: AppColors.textHint),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Player de vídeo principal (mock)
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_filled,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vídeo ${_currentVideoIndex + 1}',
                        style: AppTypography.subtitle1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toque para reproduzir',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão de play
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _showVideoDialog(widget.videos[_currentVideoIndex]);
                      },
                      child: Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Lista de vídeos
        if (widget.videos.length > 1)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black.withValues(alpha: 0.9),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(AppSpacing.sm),
                itemCount: widget.videos.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _currentVideoIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentVideoIndex = index;
                      });
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vídeo ${index + 1}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void _showVideoDialog(String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reproduzir Vídeo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Player de vídeo (Mock)',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'URL: $videoUrl',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
