import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SoundWave'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to listen to?'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @browseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse all'**
  String get browseAll;

  /// No description provided for @jumpBackIn.
  ///
  /// In en, this message translates to:
  /// **'Jump back in'**
  String get jumpBackIn;

  /// No description provided for @yourTopMixes.
  ///
  /// In en, this message translates to:
  /// **'Your top mixes'**
  String get yourTopMixes;

  /// No description provided for @featuredPremiere.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featuredPremiere;

  /// No description provided for @featuredEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is waiting'**
  String get featuredEmptyTitle;

  /// No description provided for @featuredEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Import folders or files and SoundWave will build mixes from your music.'**
  String get featuredEmptyBody;

  /// No description provided for @moodForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get moodForYou;

  /// No description provided for @moodFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get moodFocus;

  /// No description provided for @moodWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get moodWorkout;

  /// No description provided for @moodRelax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get moodRelax;

  /// No description provided for @moodNight.
  ///
  /// In en, this message translates to:
  /// **'Late night drive'**
  String get moodNight;

  /// No description provided for @yourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your library'**
  String get yourLibrary;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @likedSongs.
  ///
  /// In en, this message translates to:
  /// **'Liked songs'**
  String get likedSongs;

  /// No description provided for @tracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track} other{{count} tracks}}'**
  String tracksCount(int count);

  /// No description provided for @playlistByYou.
  ///
  /// In en, this message translates to:
  /// **'Playlist • You'**
  String get playlistByYou;

  /// No description provided for @playlistByApp.
  ///
  /// In en, this message translates to:
  /// **'Playlist • SoundWave'**
  String get playlistByApp;

  /// No description provided for @artistLabel.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artistLabel;

  /// No description provided for @albumLabel.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get albumLabel;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown album'**
  String get unknownAlbum;

  /// No description provided for @unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown title'**
  String get unknownTitle;

  /// No description provided for @playingFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playing from playlist'**
  String get playingFromPlaylist;

  /// No description provided for @playingFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Playing from album'**
  String get playingFromAlbum;

  /// No description provided for @playingFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Playing from queue'**
  String get playingFromQueue;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @noLyrics.
  ///
  /// In en, this message translates to:
  /// **'No lyrics found for this track.'**
  String get noLyrics;

  /// No description provided for @fetchingLyrics.
  ///
  /// In en, this message translates to:
  /// **'Looking up lyrics…'**
  String get fetchingLyrics;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'The queue is empty.'**
  String get queueEmpty;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat one'**
  String get repeatOne;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @unlike.
  ///
  /// In en, this message translates to:
  /// **'Remove like'**
  String get unlike;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @addSongs.
  ///
  /// In en, this message translates to:
  /// **'Add songs'**
  String get addSongs;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get newPlaylist;

  /// No description provided for @editPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Edit playlist'**
  String get editPlaylist;

  /// No description provided for @playlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist title'**
  String get playlistTitle;

  /// No description provided for @playlistTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Name your playlist…'**
  String get playlistTitleHint;

  /// No description provided for @playlistDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get playlistDescription;

  /// No description provided for @playlistDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the vibe…'**
  String get playlistDescriptionHint;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get privacy;

  /// No description provided for @privacyPublic.
  ///
  /// In en, this message translates to:
  /// **'On Home'**
  String get privacyPublic;

  /// No description provided for @privacyPrivate.
  ///
  /// In en, this message translates to:
  /// **'Library only'**
  String get privacyPrivate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changeImage;

  /// No description provided for @findMusic.
  ///
  /// In en, this message translates to:
  /// **'Let’s find some music'**
  String get findMusic;

  /// No description provided for @findMusicBody.
  ///
  /// In en, this message translates to:
  /// **'Search tracks, albums or artists to add to this playlist.'**
  String get findMusicBody;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed. Your files stay on disk.'**
  String deletePlaylistBody(String name);

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get removeFromPlaylist;

  /// No description provided for @goToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Go to album'**
  String get goToAlbum;

  /// No description provided for @goToArtist.
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get goToArtist;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepOff;

  /// No description provided for @sleepMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String sleepMinutes(int count);

  /// No description provided for @sleepEndOfTrack.
  ///
  /// In en, this message translates to:
  /// **'End of track'**
  String get sleepEndOfTrack;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get playbackSpeed;

  /// No description provided for @importMusic.
  ///
  /// In en, this message translates to:
  /// **'Import music'**
  String get importMusic;

  /// No description provided for @importFiles.
  ///
  /// In en, this message translates to:
  /// **'Import files'**
  String get importFiles;

  /// No description provided for @importFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get importFolder;

  /// No description provided for @scanDevice.
  ///
  /// In en, this message translates to:
  /// **'Scan Music folder'**
  String get scanDevice;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get scanning;

  /// No description provided for @importedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track added} other{{count} tracks added}}'**
  String importedCount(int count);

  /// No description provided for @noMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'No local music yet'**
  String get noMusicTitle;

  /// No description provided for @noMusicBody.
  ///
  /// In en, this message translates to:
  /// **'Add a folder or files from this device. SoundWave never streams — everything stays local.'**
  String get noMusicBody;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another title, artist, album or genre.'**
  String get emptySearchBody;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @genrePop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get genrePop;

  /// No description provided for @genreRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get genreRock;

  /// No description provided for @genreHipHop.
  ///
  /// In en, this message translates to:
  /// **'Hip-Hop'**
  String get genreHipHop;

  /// No description provided for @genreElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get genreElectronic;

  /// No description provided for @genreClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get genreClassical;

  /// No description provided for @genreJazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get genreJazz;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Music folders'**
  String get folders;

  /// No description provided for @noFolders.
  ///
  /// In en, this message translates to:
  /// **'No folders yet. Add one to keep your library in sync.'**
  String get noFolders;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan library'**
  String get rescan;

  /// No description provided for @removeFolder.
  ///
  /// In en, this message translates to:
  /// **'Remove folder'**
  String get removeFolder;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'SoundWave plays music that already lives on this device. Playlists, likes and mix history stay private. Jam only talks to other devices on the local network.'**
  String get aboutBody;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {value}'**
  String version(String value);

  /// No description provided for @miniPlayer.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get miniPlayer;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear search history'**
  String get clearHistory;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @sortArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get sortArtist;

  /// No description provided for @sortRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortRecentlyAdded;

  /// No description provided for @sortMostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get sortMostPlayed;

  /// No description provided for @createPlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get createPlaylistHint;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToPlaylist(String name);

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'SoundWave needs access to audio files to scan this device.'**
  String get permissionDenied;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get grantPermission;

  /// No description provided for @trackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This file is no longer available.'**
  String get trackUnavailable;

  /// No description provided for @allSongs.
  ///
  /// In en, this message translates to:
  /// **'All songs'**
  String get allSongs;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playAll;

  /// No description provided for @shuffleAll.
  ///
  /// In en, this message translates to:
  /// **'Shuffle all'**
  String get shuffleAll;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get clearQueue;

  /// No description provided for @sleepActive.
  ///
  /// In en, this message translates to:
  /// **'Sleep in {label}'**
  String sleepActive(String label);

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get addedToQueue;

  /// No description provided for @playingNext.
  ///
  /// In en, this message translates to:
  /// **'Playing next'**
  String get playingNext;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueue;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @widgetName.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get widgetName;

  /// No description provided for @widgetNothingPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get widgetNothingPlaying;

  /// No description provided for @jamTitle.
  ///
  /// In en, this message translates to:
  /// **'Jam'**
  String get jamTitle;

  /// No description provided for @jamBody.
  ///
  /// In en, this message translates to:
  /// **'A jam stays local: one device plays, everyone else can control playback, and missing files are copied to the player only for the session.'**
  String get jamBody;

  /// No description provided for @jamStart.
  ///
  /// In en, this message translates to:
  /// **'Start jam (this device plays)'**
  String get jamStart;

  /// No description provided for @jamNearby.
  ///
  /// In en, this message translates to:
  /// **'Jams on this network'**
  String get jamNearby;

  /// No description provided for @jamSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking for jams…'**
  String get jamSearching;

  /// No description provided for @jamNoneNearby.
  ///
  /// In en, this message translates to:
  /// **'No jam nearby. Start one or join with IP and PIN.'**
  String get jamNoneNearby;

  /// No description provided for @jamManual.
  ///
  /// In en, this message translates to:
  /// **'Join manually'**
  String get jamManual;

  /// No description provided for @jamHostHint.
  ///
  /// In en, this message translates to:
  /// **'IP:port or soundwave:// link'**
  String get jamHostHint;

  /// No description provided for @jamPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get jamPin;

  /// No description provided for @jamJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get jamJoin;

  /// No description provided for @jamJoinName.
  ///
  /// In en, this message translates to:
  /// **'Join “{name}”'**
  String jamJoinName(String name);

  /// No description provided for @jamLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave jam'**
  String get jamLeave;

  /// No description provided for @jamYouArePlayer.
  ///
  /// In en, this message translates to:
  /// **'This device is the player'**
  String get jamYouArePlayer;

  /// No description provided for @jamYouAreGuest.
  ///
  /// In en, this message translates to:
  /// **'You’re listening through the player'**
  String get jamYouAreGuest;

  /// No description provided for @jamNoIp.
  ///
  /// In en, this message translates to:
  /// **'No local IP found. Check Wi-Fi or start a hotspot.'**
  String get jamNoIp;

  /// No description provided for @jamCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get jamCopied;

  /// No description provided for @jamCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy join link'**
  String get jamCopyLink;

  /// No description provided for @jamHotspot.
  ///
  /// In en, this message translates to:
  /// **'Start hotspot for guests'**
  String get jamHotspot;

  /// No description provided for @jamHotspotStop.
  ///
  /// In en, this message translates to:
  /// **'Stop hotspot'**
  String get jamHotspotStop;

  /// No description provided for @jamHotspotActive.
  ///
  /// In en, this message translates to:
  /// **'Hotspot {ssid} · password {password}'**
  String jamHotspotActive(String ssid, String password);

  /// No description provided for @jamMembers.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get jamMembers;

  /// No description provided for @jamRolePlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get jamRolePlayer;

  /// No description provided for @jamRoleGuest.
  ///
  /// In en, this message translates to:
  /// **'Can control'**
  String get jamRoleGuest;

  /// No description provided for @jamUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Jam isn’t available in the web build.'**
  String get jamUnsupported;

  /// No description provided for @jamHosting.
  ///
  /// In en, this message translates to:
  /// **'Jam live · player · {count} devices'**
  String jamHosting(int count);

  /// No description provided for @jamListening.
  ///
  /// In en, this message translates to:
  /// **'Jam · player: {name}'**
  String jamListening(String name);

  /// No description provided for @jamAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String jamAddedBy(String name);

  /// No description provided for @jamTransferPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for file'**
  String get jamTransferPending;

  /// No description provided for @jamTransferProgress.
  ///
  /// In en, this message translates to:
  /// **'Transfer {percent}%'**
  String jamTransferProgress(int percent);

  /// No description provided for @jamTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get jamTransferFailed;

  /// No description provided for @jamTransferReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get jamTransferReady;

  /// No description provided for @jamTransferLocal.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get jamTransferLocal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
