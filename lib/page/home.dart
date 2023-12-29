import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mini_music/widgets/control_widget.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;

  final _playlist = ConcatenatingAudioSource(
    children: [
      AudioSource.uri( 
        Uri.parse('asset:///assets/audio/over.mp3'),
        tag: MediaItem(
          id: '0',
          title: 'over',
          artist: 'limoblaze ft elle limebear',
          artUri: Uri.parse('https://i0.wp.com/justnaija.com/uploads/2023/11/Limoblaze-Over-artwork.jpeg')
        )
        ),
       AudioSource.uri( 
        Uri.parse('asset:///assets/audio/desire.mp3'),
        tag: MediaItem(
          id: '1',
          title: 'desire',
          artist: 'limoblaze',
          artUri: Uri.parse('https://trendybeatz.com/images/Limoblaze-Sunday-In-Lagos-EPArtwork1.jpg')
        )
        ),
    ]
    );

  Stream<PositionData> get _positionDataStream => 
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        )
        );

  @override
  void initState() {
    
    _audioPlayer = AudioPlayer();
    _init();
    super.initState();
  }

  Future<void> _init() async {
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setAudioSource(_playlist);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor:  Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.keyboard_arrow_down_rounded)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: 
          LinearGradient(
            colors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.indigo,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )

          // LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Color(0xff2E305F),  Color.fromARGB(255, 103, 104, 153)]
          // )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<SequenceState?>(
              stream: _audioPlayer.sequenceStateStream, 
              builder: (context, snapshot) {
                final sequenceState = snapshot.data;
                if (sequenceState?.sequence.isEmpty ?? true) {
                  return const SizedBox();
                }
                final metadata = sequenceState!.currentSource!.tag as MediaItem;
                return MediaMetadata(
                  title: metadata.title, 
                  artist: metadata.artist!, 
                  albumArtUrl: metadata.artUri?.toString() ?? ''
                  );
              }
              ),
              const SizedBox(height: 20,),
            StreamBuilder(
              stream: _positionDataStream, 
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  barHeight: 8,
                  baseBarColor: Colors.grey[600],
                  bufferedBarColor: Colors.grey,
                  progressBarColor: Colors.yellow,
                  thumbColor: Colors.yellow,
                  timeLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: _audioPlayer.seek,
                  );
              }),
            const SizedBox(height: 20,),
            Controls(audioPlayer: _audioPlayer),
            const SizedBox(height: 200,),
            const Text(
              'built with ❤️ by kiddo for kiddo',
              style: TextStyle(color: Colors.white),
              )
          ],
        ),
      ),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class MediaMetadata extends StatelessWidget{
  final String title;
  final String artist;
  final String albumArtUrl;

MediaMetadata({required this.title, required this.artist, required this.albumArtUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 4),
                    blurRadius: 4,                  )
                ],
                borderRadius: BorderRadius.circular(10),
                
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: albumArtUrl,
                  height: 300,
                  ),
              ),
              ),
              const SizedBox(height: 20,),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8,),
              Text(
                artist,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
              ),
      ]
    );
  }
}

