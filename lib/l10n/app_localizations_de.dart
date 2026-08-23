// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'SoundWave';

  @override
  String get navHome => 'Entdecken';

  @override
  String get navSearch => 'Suche';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get settings => 'Einstellungen';

  @override
  String get searchHint => 'Wonach möchtest du hören?';

  @override
  String get recentSearches => 'Zuletzt gesucht';

  @override
  String get browseAll => 'Alle durchstöbern';

  @override
  String get jumpBackIn => 'Weitermachen';

  @override
  String get yourTopMixes => 'Deine Top-Mixes';

  @override
  String get featuredPremiere => 'Empfohlen';

  @override
  String get featuredEmptyTitle => 'Deine Bibliothek wartet';

  @override
  String get featuredEmptyBody =>
      'Importiere Ordner oder Dateien – SoundWave baut Mixes aus deiner Musik.';

  @override
  String get moodForYou => 'Für dich';

  @override
  String get moodFocus => 'Fokus';

  @override
  String get moodWorkout => 'Workout';

  @override
  String get moodRelax => 'Entspannen';

  @override
  String get moodNight => 'Nachtfahrt';

  @override
  String get yourLibrary => 'Deine Bibliothek';

  @override
  String get playlists => 'Playlists';

  @override
  String get artists => 'Künstler';

  @override
  String get albums => 'Alben';

  @override
  String get songs => 'Titel';

  @override
  String get genres => 'Genres';

  @override
  String get likedSongs => 'Lieblingssongs';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
    );
    return '$_temp0';
  }

  @override
  String get playlistByYou => 'Playlist • Du';

  @override
  String get playlistByApp => 'Playlist • SoundWave';

  @override
  String get artistLabel => 'Künstler';

  @override
  String get albumLabel => 'Album';

  @override
  String get unknownArtist => 'Unbekannter Künstler';

  @override
  String get unknownAlbum => 'Unbekanntes Album';

  @override
  String get unknownTitle => 'Unbekannter Titel';

  @override
  String get playingFromPlaylist => 'Spielt aus Playlist';

  @override
  String get playingFromAlbum => 'Spielt aus Album';

  @override
  String get playingFromQueue => 'Spielt aus Warteschlange';

  @override
  String get lyrics => 'Songtext';

  @override
  String get noLyrics => 'Kein Songtext für diesen Titel gefunden.';

  @override
  String get fetchingLyrics => 'Songtext wird gesucht…';

  @override
  String get queue => 'Warteschlange';

  @override
  String get queueEmpty => 'Die Warteschlange ist leer.';

  @override
  String get more => 'Mehr';

  @override
  String get shuffle => 'Zufall';

  @override
  String get repeat => 'Wiederholen';

  @override
  String get repeatOne => 'Titel wiederholen';

  @override
  String get like => 'Gefällt mir';

  @override
  String get unlike => 'Gefällt mir nicht mehr';

  @override
  String get addToPlaylist => 'Zu Playlist hinzufügen';

  @override
  String get addSongs => 'Titel hinzufügen';

  @override
  String get newPlaylist => 'Neue Playlist';

  @override
  String get editPlaylist => 'Playlist bearbeiten';

  @override
  String get playlistTitle => 'Playlist-Titel';

  @override
  String get playlistTitleHint => 'Gib der Playlist einen Namen…';

  @override
  String get playlistDescription => 'Beschreibung (optional)';

  @override
  String get playlistDescriptionHint => 'Beschreibe die Stimmung…';

  @override
  String get privacy => 'Sichtbarkeit';

  @override
  String get privacyPublic => 'Auf Home';

  @override
  String get privacyPrivate => 'Nur Bibliothek';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get back => 'Zurück';

  @override
  String get changeImage => 'Bild ändern';

  @override
  String get findMusic => 'Lass uns Musik finden';

  @override
  String get findMusicBody =>
      'Suche Titel, Alben oder Künstler für diese Playlist.';

  @override
  String get deletePlaylistTitle => 'Playlist löschen?';

  @override
  String deletePlaylistBody(String name) {
    return '„$name“ wird entfernt. Deine Dateien bleiben erhalten.';
  }

  @override
  String get removeFromPlaylist => 'Aus Playlist entfernen';

  @override
  String get goToAlbum => 'Zum Album';

  @override
  String get goToArtist => 'Zum Künstler';

  @override
  String get sleepTimer => 'Sleep-Timer';

  @override
  String get sleepOff => 'Aus';

  @override
  String sleepMinutes(int count) {
    return '$count Min.';
  }

  @override
  String get sleepEndOfTrack => 'Ende des Titels';

  @override
  String get playbackSpeed => 'Tempo';

  @override
  String get importMusic => 'Musik importieren';

  @override
  String get importFiles => 'Dateien importieren';

  @override
  String get importFolder => 'Ordner hinzufügen';

  @override
  String get scanDevice => 'Musik-Ordner scannen';

  @override
  String get scanning => 'Scannen…';

  @override
  String importedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel hinzugefügt',
      one: '1 Titel hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get noMusicTitle => 'Noch keine lokale Musik';

  @override
  String get noMusicBody =>
      'Füge einen Ordner oder Dateien von diesem Gerät hinzu. SoundWave streamt nicht – alles bleibt lokal.';

  @override
  String get emptySearchTitle => 'Nichts gefunden';

  @override
  String get emptySearchBody =>
      'Probiere einen anderen Titel, Künstler, ein Album oder Genre.';

  @override
  String get results => 'Ergebnisse';

  @override
  String get genrePop => 'Pop';

  @override
  String get genreRock => 'Rock';

  @override
  String get genreHipHop => 'Hip-Hop';

  @override
  String get genreElectronic => 'Electronic';

  @override
  String get genreClassical => 'Klassik';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get folders => 'Musikordner';

  @override
  String get noFolders =>
      'Noch keine Ordner. Füge einen hinzu, um die Bibliothek aktuell zu halten.';

  @override
  String get rescan => 'Bibliothek aktualisieren';

  @override
  String get removeFolder => 'Ordner entfernen';

  @override
  String get about => 'Über';

  @override
  String get aboutBody =>
      'SoundWave spielt Musik, die bereits auf diesem Gerät liegt. Playlists, Likes und Mix-Verlauf bleiben privat.';

  @override
  String version(String value) {
    return 'Version $value';
  }

  @override
  String get miniPlayer => 'Jetzt läuft';

  @override
  String get play => 'Abspielen';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Weiter';

  @override
  String get previous => 'Zurück';

  @override
  String get clearHistory => 'Suchverlauf löschen';

  @override
  String get sortTitle => 'Titel';

  @override
  String get sortArtist => 'Künstler';

  @override
  String get sortRecentlyAdded => 'Zuletzt hinzugefügt';

  @override
  String get sortMostPlayed => 'Meistgespielt';

  @override
  String get createPlaylistHint => 'Playlist erstellen';

  @override
  String addedToPlaylist(String name) {
    return 'Zu $name hinzugefügt';
  }

  @override
  String get permissionDenied =>
      'SoundWave braucht Zugriff auf Audiodateien, um dieses Gerät zu scannen.';

  @override
  String get grantPermission => 'Zugriff erlauben';

  @override
  String get trackUnavailable => 'Diese Datei ist nicht mehr verfügbar.';

  @override
  String get allSongs => 'Alle Titel';

  @override
  String get playAll => 'Alle abspielen';

  @override
  String get shuffleAll => 'Zufall alle';

  @override
  String get nowPlaying => 'Jetzt läuft';

  @override
  String get upNext => 'Als Nächstes';

  @override
  String get clearQueue => 'Warteschlange leeren';

  @override
  String sleepActive(String label) {
    return 'Sleep in $label';
  }

  @override
  String get playNext => 'Als Nächstes spielen';

  @override
  String get addToQueue => 'Zur Warteschlange';

  @override
  String get addedToQueue => 'Zur Warteschlange hinzugefügt';

  @override
  String get playingNext => 'Spielt als Nächstes';

  @override
  String get removeFromQueue => 'Aus Warteschlange entfernen';

  @override
  String get open => 'Öffnen';

  @override
  String get widgetName => 'Jetzt läuft';

  @override
  String get widgetNothingPlaying => 'Nichts spielt';
}
