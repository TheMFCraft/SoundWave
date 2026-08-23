// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SoundWave';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navLibrary => 'Library';

  @override
  String get settings => 'Settings';

  @override
  String get searchHint => 'What do you want to listen to?';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get browseAll => 'Browse all';

  @override
  String get jumpBackIn => 'Jump back in';

  @override
  String get yourTopMixes => 'Your top mixes';

  @override
  String get featuredPremiere => 'Featured';

  @override
  String get featuredEmptyTitle => 'Your library is waiting';

  @override
  String get featuredEmptyBody =>
      'Import folders or files and SoundWave will build mixes from your music.';

  @override
  String get moodForYou => 'For you';

  @override
  String get moodFocus => 'Focus';

  @override
  String get moodWorkout => 'Workout';

  @override
  String get moodRelax => 'Relax';

  @override
  String get moodNight => 'Late night drive';

  @override
  String get yourLibrary => 'Your library';

  @override
  String get playlists => 'Playlists';

  @override
  String get artists => 'Artists';

  @override
  String get albums => 'Albums';

  @override
  String get songs => 'Songs';

  @override
  String get genres => 'Genres';

  @override
  String get likedSongs => 'Liked songs';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String get playlistByYou => 'Playlist • You';

  @override
  String get playlistByApp => 'Playlist • SoundWave';

  @override
  String get artistLabel => 'Artist';

  @override
  String get albumLabel => 'Album';

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get unknownAlbum => 'Unknown album';

  @override
  String get unknownTitle => 'Unknown title';

  @override
  String get playingFromPlaylist => 'Playing from playlist';

  @override
  String get playingFromAlbum => 'Playing from album';

  @override
  String get playingFromQueue => 'Playing from queue';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get noLyrics => 'No lyrics found for this track.';

  @override
  String get fetchingLyrics => 'Looking up lyrics…';

  @override
  String get queue => 'Queue';

  @override
  String get queueEmpty => 'The queue is empty.';

  @override
  String get more => 'More';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatOne => 'Repeat one';

  @override
  String get like => 'Like';

  @override
  String get unlike => 'Remove like';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get addSongs => 'Add songs';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get editPlaylist => 'Edit playlist';

  @override
  String get playlistTitle => 'Playlist title';

  @override
  String get playlistTitleHint => 'Name your playlist…';

  @override
  String get playlistDescription => 'Description (optional)';

  @override
  String get playlistDescriptionHint => 'Describe the vibe…';

  @override
  String get privacy => 'Visibility';

  @override
  String get privacyPublic => 'On Home';

  @override
  String get privacyPrivate => 'Library only';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get changeImage => 'Change image';

  @override
  String get findMusic => 'Let’s find some music';

  @override
  String get findMusicBody =>
      'Search tracks, albums or artists to add to this playlist.';

  @override
  String get deletePlaylistTitle => 'Delete playlist?';

  @override
  String deletePlaylistBody(String name) {
    return '“$name” will be removed. Your files stay on disk.';
  }

  @override
  String get removeFromPlaylist => 'Remove from playlist';

  @override
  String get goToAlbum => 'Go to album';

  @override
  String get goToArtist => 'Go to artist';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get sleepOff => 'Off';

  @override
  String sleepMinutes(int count) {
    return '$count min';
  }

  @override
  String get sleepEndOfTrack => 'End of track';

  @override
  String get playbackSpeed => 'Speed';

  @override
  String get importMusic => 'Import music';

  @override
  String get importFiles => 'Import files';

  @override
  String get importFolder => 'Add folder';

  @override
  String get scanDevice => 'Scan Music folder';

  @override
  String get scanning => 'Scanning…';

  @override
  String importedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks added',
      one: '1 track added',
    );
    return '$_temp0';
  }

  @override
  String get noMusicTitle => 'No local music yet';

  @override
  String get noMusicBody =>
      'Add a folder or files from this device. SoundWave never streams — everything stays local.';

  @override
  String get emptySearchTitle => 'Nothing matches';

  @override
  String get emptySearchBody => 'Try another title, artist, album or genre.';

  @override
  String get results => 'Results';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreRock => 'Rock';

  @override
  String get genreHipHop => 'Hip-Hop';

  @override
  String get genreElectronic => 'Electronic';

  @override
  String get genreClassical => 'Classical';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get folders => 'Music folders';

  @override
  String get noFolders =>
      'No folders yet. Add one to keep your library in sync.';

  @override
  String get rescan => 'Rescan library';

  @override
  String get removeFolder => 'Remove folder';

  @override
  String get about => 'About';

  @override
  String get aboutBody =>
      'SoundWave plays music that already lives on this device. Playlists, likes and mix history stay private.';

  @override
  String version(String value) {
    return 'Version $value';
  }

  @override
  String get miniPlayer => 'Now playing';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get clearHistory => 'Clear search history';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortRecentlyAdded => 'Recently added';

  @override
  String get sortMostPlayed => 'Most played';

  @override
  String get createPlaylistHint => 'Create playlist';

  @override
  String addedToPlaylist(String name) {
    return 'Added to $name';
  }

  @override
  String get permissionDenied =>
      'SoundWave needs access to audio files to scan this device.';

  @override
  String get grantPermission => 'Allow access';

  @override
  String get trackUnavailable => 'This file is no longer available.';

  @override
  String get allSongs => 'All songs';

  @override
  String get playAll => 'Play all';

  @override
  String get shuffleAll => 'Shuffle all';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get upNext => 'Up next';

  @override
  String get clearQueue => 'Clear queue';

  @override
  String sleepActive(String label) {
    return 'Sleep in $label';
  }

  @override
  String get playNext => 'Play next';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get addedToQueue => 'Added to queue';

  @override
  String get playingNext => 'Playing next';

  @override
  String get removeFromQueue => 'Remove from queue';

  @override
  String get open => 'Open';

  @override
  String get widgetName => 'Now playing';

  @override
  String get widgetNothingPlaying => 'Nothing playing';
}
