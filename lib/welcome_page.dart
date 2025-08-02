import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert'; // Added for jsonDecode
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'debug_page.dart';
import 'pages/api_lessons_page.dart';
import 'services/api_service.dart';
import 'services/file_service.dart';
import 'widgets/file_handler.dart';
import 'widgets/download_manager.dart';
import 'widgets/cross_platform_pdf_viewer.dart';
import 'models/lesson.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  // Audio content data for Tabellen/Wortlisten
  final Map<String, Map<String, dynamic>> audioContent = {
    'Tab 1_1 - Grußformeln und Befinden - informell': {
      'title': 'Grußformeln und Befinden - informell',
      'phrases': [
        {'german': 'Hallo.', 'literal': 'Hello.', 'english': 'Hello.'},
        {'german': 'Wie geht\'s?', 'literal': 'How goes\'it?', 'english': 'How are you?'},
        {'german': 'Mir geht\'s gut/nicht gut.', 'literal': 'Me goes\'it good/not good.', 'english': 'I\'m doing well/not well.'},
        {'german': 'Und dir?', 'literal': 'And you?', 'english': 'And you?'},
        {'german': 'Mir geht\'s auch gut/nicht gut.', 'literal': 'Me goes\'it also good/not good.', 'english': 'I\'m also doing well/not well.'},
        {'german': 'Tschüss.', 'literal': 'Bye.', 'english': 'Bye.'},
        {'german': 'Tschau./Ciao.', 'literal': 'Ciao.', 'english': 'Ciao.'},
      ],
    },
    'Tab 1_2 - Grußformeln und Befinden - formell': {
      'title': 'Grußformeln und Befinden - formell',
      'phrases': [
        {'german': 'Guten Tag.', 'literal': 'Good day.', 'english': 'Good day.'},
        {'german': 'Grüß Gott. [österr.]', 'literal': 'Greet God.', 'english': 'Greetings. [Austrian]'},
        {'german': 'Wie geht es Ihnen?', 'literal': 'How goes\'it You?', 'english': 'How are you?'},
        {'german': 'Und Ihnen?', 'literal': 'And You?', 'english': 'And you?'},
        {'german': 'Auf Wiedersehen.', 'literal': 'On again-see.', 'english': 'Goodbye.'},
        {'german': 'Auf Wiederschauen. [südd., österr.]', 'literal': 'On again-look.', 'english': 'Goodbye. [South German, Austrian]'},
        {'german': 'Schönen Tag (noch).', 'literal': 'Beautiful day ([ahead]).', 'english': 'Have a nice day.'},
      ],
    },
    'Tab 1_3 - Vorstellung - informell': {
      'title': 'Vorstellung - informell',
      'phrases': [
        {'german': 'Wie heißt du?', 'literal': 'How [are called] you?', 'english': 'What\'s your name?'},
        {'german': 'Ich heiße ...', 'literal': 'I [am called] ...', 'english': 'My name is ...'},
        {'german': 'Woher kommst du?', 'literal': 'Where-[from] come you?', 'english': 'Where are you from?'},
        {'german': 'Ich komme aus ...', 'literal': 'I come out ...', 'english': 'I come from ...'},
        {'german': 'Und du?', 'literal': 'And you?', 'english': 'And you?'},
        {'german': 'Wo wohnst du?', 'literal': 'Where reside you?', 'english': 'Where do you live?'},
        {'german': 'Ich wohne in ...', 'literal': 'I reside in ...', 'english': 'I live in ...'},
      ],
    },
    'Tab 1_4 - Vorstellung - formell': {
      'title': 'Vorstellung - formell',
      'phrases': [
        {'german': 'Wie heißen Sie?', 'literal': 'How [are called] You?', 'english': 'What\'s your name?'},
        {'german': 'Ich heiße...', 'literal': 'I [am called]...', 'english': 'My name is...'},
        {'german': 'Woher kommen Sie?', 'literal': 'Where-[from] come You?', 'english': 'Where are you from?'},
        {'german': 'Ich komme aus ...', 'literal': 'I come out ...', 'english': 'I come from ...'},
        {'german': 'Und Sie?', 'literal': 'And You?', 'english': 'And you?'},
        {'german': 'Wo wohnen Sie?', 'literal': 'Where reside You?', 'english': 'Where do you live?'},
        {'german': 'Ich wohne in ...', 'literal': 'I reside in ...', 'english': 'I live in ...'},
      ],
    },
    'Tab 1_5 - Vorstellung - Alternative': {
      'title': 'Vorstellung - Alternative',
      'phrases': [
        {'german': 'Wie ist dein/Ihr Name?', 'literal': 'How is your/Your name?', 'english': 'What is your name?'},
        {'german': 'Mein Name ist ...', 'literal': 'My name is', 'english': 'My name is ...'},
        {'german': 'Wo lebst du/leben Sie?', 'literal': 'Where live you/live You?', 'english': 'Where do you live?'},
        {'german': 'Ich lebe in ...', 'literal': 'I live in...', 'english': 'I live in...'},
      ],
    },
    'Tab 1_8 - Ergänzung zum Dialog': {
      'title': 'Ergänzung zum Dialog',
      'phrases': [
        {'german': '(Es) freut mich, dich/Sie kennenzulernen.', 'literal': '(It) pleases me, you/You know-to', 'english': 'Nice to meet you.'},
        {'german': 'Ich muss jetzt gehen.', 'literal': 'I must now go.', 'english': 'I have to go now.'},
        {'german': 'Ich muss jetzt leider los.', 'literal': 'I must now unfortunately [off].', 'english': 'I have to go now, unfortunately.'},
      ],
    },
    // Lektion 2 Content
    'Tab 2_1 - Regionale Begrüßungen - ugs': {
      'title': 'Regionale Begrüßungen [ugs]',
      'phrases': [
        {'german': 'Grüß dich. [südd., österr.]', 'literal': 'Greet you.', 'english': 'Hi there. [Southern/Austrian]'},
        {'german': 'Grüezi. [schweiz.]', 'literal': 'Hello.', 'english': 'Hi there. [Swiss]'},
        {'german': 'Servus. [österr.]', 'literal': 'Hey./Bye.', 'english': 'Hey. / Bye. [Austrian]'},
        {'german': 'Moin. [nordd.]', 'literal': 'Hello.', 'english': 'Hey./Bye. [Northern]'},
      ],
    },
    'Tab 2_2 - Begrüßungen': {
      'title': 'Begrüßungen',
      'phrases': [
        {'german': 'Guten Morgen.', 'literal': 'Good mornir', 'english': 'Good morning'},
        {'german': 'Guten Abend.', 'literal': 'Good evenin', 'english': 'Good evening'},
        {'german': 'Willkommen.', 'literal': 'Welcome.', 'english': 'Welcome.'},
      ],
    },
    'Tab 2_3 - Alter und Hobbys - informell': {
      'title': 'Alter und Hobbys - informell',
      'phrases': [
        {'german': 'Wie alt bist du?', 'literal': 'How old are', 'english': 'How old are you?'},
        {'german': 'Ich bin ... Jahre alt.', 'literal': 'I am ... years', 'english': 'I am ... years old.'},
        {'german': 'Hast du Hobbys?', 'literal': 'Have you ho', 'english': 'Do you have hobbies?'},
        {'german': 'Ich lese/koche gern(e).', 'literal': 'I read/cook g', 'english': 'I like reading/cooking.'},
        {'german': 'Was machst du in deiner Freizeit?', 'literal': 'What makey', 'english': 'What do you do in your free time?'},
        {'german': 'Ich höre gern(e) Musik.', 'literal': 'I hear gladly', 'english': 'I like listening to music.'},
        {'german': 'Ich mag Sport.', 'literal': 'I like sport.', 'english': 'I like sports.'},
      ],
    },
    'Tab 2_4 - Alter und Hobbys - formell': {
      'title': 'Alter und Hobbys - formell',
      'phrases': [
        {'german': 'Wie alt sind Sie?', 'literal': 'How old are', 'english': 'How old are you?'},
        {'german': 'Haben Sie Hobbys?', 'literal': 'Have You ho', 'english': 'Do you have hobbies?'},
        {'german': 'Was machen Sie in Ihrer Freizeit?', 'literal': 'What make', 'english': 'What do you do in your free time?'},
      ],
    },
    'Tab 2_5 - Arbeit - informell': {
      'title': 'Arbeit - informell',
      'phrases': [
        {'german': 'Was arbeitest du?', 'literal': 'What work y', 'english': 'What do you do for work?'},
        {'german': 'Ich arbeite als ...', 'literal': 'I work as ...', 'english': 'I work as ...'},
        {'german': 'Ich bin ...', 'literal': 'I am ...', 'english': 'I am ...'},
        {'german': 'Wo arbeitest du?', 'literal': 'Where work', 'english': 'Where do you work?'},
        {'german': 'Ich arbeite bei ...', 'literal': 'I work by ...', 'english': 'I work at ...'},
      ],
    },
    'Tab 2_6 - Arbeit - formell': {
      'title': 'Arbeit - formell',
      'phrases': [
        {'german': 'Was arbeiten Sie?', 'literal': 'What work Y', 'english': 'What do you do for work?'},
        {'german': 'Wo arbeiten Sie?', 'literal': 'Where work', 'english': 'Where do you work?'},
      ],
    },
    'Tab 2_7 - Studium - informell und formell': {
      'title': 'Studium - informell und formell',
      'phrases': [
        {'german': 'Was studierst du?', 'literal': 'What study', 'english': 'What do you study?'},
        {'german': 'Was studieren Sie?', 'literal': 'What study', 'english': 'What do you study?'},
        {'german': 'Ich bin Student/Studentin.', 'literal': 'I am student', 'english': 'I am a student.'},
        {'german': 'Ich studiere ...', 'literal': 'I study ...', 'english': 'I study ...'},
      ],
    },
    'Tab 2_8 - Studium - Verneinung_arbeiten und studieren': {
      'title': 'Verneinung „arbeiten" und „studieren"',
      'phrases': [
        {'german': 'Ich arbeite nicht.', 'literal': 'I work not.', 'english': 'I don\'t work.'},
        {'german': 'Ich studiere nicht.', 'literal': 'I study not.', 'english': 'I don\'t study.'},
      ],
    },
    'Tab 2_9 - Berufliche Situation - Alternativen': {
      'title': 'Berufliche Situation - Alternativen',
      'phrases': [
        {'german': 'Ich habe (noch/momentan) keinen Job.', 'literal': 'I have (still/m', 'english': 'I don\'t have a job (yet/currently).'},
        {'german': 'Ich suche Arbeit.', 'literal': 'I seek work.', 'english': 'I am looking for work.'},
      ],
    },
    'Tab 2_10 - Elliptische Gegenfrage - informell und formell': {
      'title': 'Gegenfrage - informell und formell',
      'phrases': [
        {'german': 'Und du?', 'literal': 'And you?', 'english': 'And you?'},
        {'german': 'Und Sie?', 'literal': 'And You?', 'english': 'And you?'},
      ],
    },
    'Tab 2_13 - Verabschiedungen': {
      'title': 'Verabschiedungen',
      'phrases': [
        {'german': 'Baba.', 'literal': 'Bye-bye.', 'english': 'Bye-bye.'},
        {'german': 'Mach\'s gut.', 'literal': 'Make\'it good', 'english': 'Take care.'},
        {'german': 'Bis später.', 'literal': 'Until later.', 'english': 'See you later.'},
        {'german': 'Bis morgen.', 'literal': 'Until tomorr', 'english': 'See you tomorrow.'},
        {'german': 'Bis bald.', 'literal': 'Until soon.', 'english': 'See you soon.'},
        {'german': 'Gute Nacht.', 'literal': 'Good night.', 'english': 'Good night.'},
        {'german': 'Bis zum nächsten Mal.', 'literal': 'Until to-ther', 'english': 'See you next time.'},
      ],
    },
    // Lektion 3 Content
    'Tab 3_1 - Sprachkenntnisse': {
      'title': 'Sprachkenntnisse',
      'phrases': [
        {'german': 'Ich spreche Deutsch.', 'literal': 'I speak German.', 'english': 'I speak German.'},
        {'german': 'Ich spreche kein Deutsch.', 'literal': 'I speak no German.', 'english': 'I don\'t speak German.'},
        {'german': 'Ich spreche nur Englisch.', 'literal': 'I speak only English.', 'english': 'I only speak English.'},
        {'german': 'Sprichst du Englisch?', 'literal': 'Speak you English?', 'english': 'Do you speak English?'},
        {'german': 'Sprechen Sie Englisch?', 'literal': 'Speak You English?', 'english': 'Do you speak English?'},
        {'german': 'Auf Englisch, bitte.', 'literal': 'On English, please.', 'english': 'In English, please.'},
      ],
    },
    'Tab 3_2 - Sprachkenntnisse - Variationen': {
      'title': 'Sprachkenntnisse - Variationen',
      'phrases': [
        {'german': 'Ich spreche (noch) nicht.', 'literal': 'I speak (still) not.', 'english': 'I don\'t speak (yet).'},
        {'german': 'Ich spreche leider nicht.', 'literal': 'I speak unfortunately not.', 'english': 'I don\'t speak, unfortunately.'},
      ],
    },
    'Tab 3_3 - Verständnisprobleme': {
      'title': 'Verständnisprobleme',
      'phrases': [
        {'german': 'Ich verstehe nicht.', 'literal': 'I understand not.', 'english': 'I don\'t understand.'},
        {'german': 'Ich habe das nicht verstanden.', 'literal': 'I have that not understood.', 'english': 'I didn\'t understand that.'},
        {'german': 'Ich habe dich/Sie nicht verstanden.', 'literal': 'I have you/You (formal) not understood.', 'english': 'I didn\'t understand you.'},
        {'german': 'Kannst du bitte wiederholen?', 'literal': 'Can you please repeat?', 'english': 'Can you please repeat?'},
        {'german': 'Könnten Sie bitte wiederholen?', 'literal': 'Could You please repeat?', 'english': 'Could you please repeat?'},
      ],
    },
    'Tab 3_4 - um Wiederholung bitten': {
      'title': 'um Wiederholung bitten',
      'phrases': [
        {'german': 'Entschuldigung?', 'literal': 'Apology?', 'english': 'Pardon?'},
        {'german': 'Wie bitte?', 'literal': 'How please?', 'english': 'Pardon?'},
        {'german': 'Kannst du das wiederholen?', 'literal': 'Can you that repeat?', 'english': 'Can you repeat that?'},
        {'german': 'Könnten Sie das wiederholen?', 'literal': 'Could You that repeat?', 'english': 'Could you repeat that?'},
        {'german': 'Noch mal, bitte.', 'literal': '[Once again], please.', 'english': 'Once again, please.'},
      ],
    },
    'Tab 3_5 - Entschuldigung als Ansprache': {
      'title': '„Entschuldigung" als Ansprache',
      'phrases': [
        {'german': 'Entschuldigung,...', 'literal': 'Apology,...', 'english': 'Sorry.../Excuse me.'},
        {'german': 'Entschuldige,...', 'literal': 'Excuse,...', 'english': 'Sorry.../Excuse me.'},
        {'german': 'Entschuldigen Sie,...', 'literal': 'Excuse You,...', 'english': 'Sorry.../Excuse me.'},
      ],
    },
    'Tab 3_6 - Entschuldigung - Variationen': {
      'title': '„Entschuldigung"-Variationen',
      'phrases': [
        {'german': 'Entschuldigung.', 'literal': 'Apology.', 'english': 'Excuse me.'},
        {'german': 'Entschuldige.', 'literal': 'Excuse.', 'english': 'Excuse me.'},
        {'german': 'Entschuldigen Sie.', 'literal': 'Excuse You.', 'english': 'Excuse me.'},
      ],
    },
    // Lektion 4 Content
    'Tab 4_1 - ja, nein, vielleicht': {
      'title': 'Ja, Nein, Vielleicht',
      'phrases': [
        {'german': 'Ja.', 'literal': 'Yes.', 'english': 'Yes.'},
        {'german': 'Nein.', 'literal': 'No.', 'english': 'No.'},
        {'german': 'Vielleicht.', 'literal': 'Maybe.', 'english': 'Maybe.'},
      ],
    },
    'Tab 4_2 - Bestätigung und Verneinung': {
      'title': 'Bestätigung und Verneinung',
      'phrases': [
        {'german': 'Natürlich (nicht).', 'literal': 'Natural (not).', 'english': 'Of course (not).'},
        {'german': 'Sicher (nicht).', 'literal': 'Sure (not).', 'english': 'Sure/certainly (not).'},
        {'german': 'Absolut (nicht).', 'literal': 'Absolute (not).', 'english': 'Absolutely (not).'},
      ],
    },
    'Tab 4_3 - danke, bitte, gerne': {
      'title': 'Danke, Bitte, Gern(e)',
      'phrases': [
        {'german': 'Danke.', 'literal': 'Thanks.', 'english': 'Thanks.'},
        {'german': 'Bitte.', 'literal': 'Please.', 'english': 'Please./You\'re welcome.'},
        {'german': 'Gern(e).', 'literal': 'Gladly.', 'english': 'You\'re welcome.'},
      ],
    },
    'Tab 4_4 - danke - Variationen': {
      'title': 'Danke-Variationen',
      'phrases': [
        {'german': 'Danke schön.', 'literal': 'Thanks beautiful.', 'english': 'Thank you very much.'},
        {'german': 'Danke sehr.', 'literal': 'Thanks very.', 'english': 'Thank you very much.'},
        {'german': 'Vielen Dank.', 'literal': 'Many thanks.', 'english': 'Many thanks.'},
      ],
    },
    'Tab 4_5 - bitte und gerne - Variationen': {
      'title': 'Bitte und Gern(e)-Variationen',
      'phrases': [
        {'german': 'Bitte schön.', 'literal': 'Please beautiful.', 'english': 'Here you go./You\'re welcome.'},
        {'german': 'Bitte sehr.', 'literal': 'Please very.', 'english': 'Here you go./You\'re welcome.'},
        {'german': 'Gern(e) geschehen.', 'literal': 'Gladly happened.', 'english': 'You\'re welcome.'},
      ],
    },
    'Tab 4_6 - Fahrkarte und Identifikation': {
      'title': 'Fahrkarte und Identifikation',
      'phrases': [
        {'german': 'Ihr Name bitte.', 'literal': 'Your name please.', 'english': 'Your name please.'},
        {'german': 'Die Fahrkarte bitte.', 'literal': 'The drive-card please.', 'english': 'The ticket, please.'},
        {'german': 'Ihren Reisepass bitte.', 'literal': 'Your travel-pass please.', 'english': 'Your passport, please.'},
        {'german': 'Ihren Führerschein bitte.', 'literal': 'Your leader-note please.', 'english': 'Your driving license, please.'},
        {'german': 'Einen Ausweis bitte.', 'literal': 'An ID please.', 'english': 'An ID, please.'},
      ],
    },
    'Tab 4_7 - warten und folgen': {
      'title': 'Warten und Folgen',
      'phrases': [
        {'german': 'Einen Moment bitte.', 'literal': 'One moment please.', 'english': 'One moment, please.'},
        {'german': 'Bitte warte kurz.', 'literal': 'Please wait short.', 'english': 'Please wait a moment.'},
        {'german': 'Bitte warten Sie.', 'literal': 'Please wait You.', 'english': 'Please wait.'},
        {'german': 'Komm bitte.', 'literal': 'Come please.', 'english': 'Come with me, please.'},
        {'german': 'Kommen Sie bitte.', 'literal': 'Come You please.', 'english': 'Come with me, please.'},
        {'german': 'Bitte folge mir.', 'literal': 'Please follow me.', 'english': 'Please follow me.'},
        {'german': 'Bitte folgen Sie.', 'literal': 'Please follow You.', 'english': 'Please follow me.'},
      ],
    },
    'Tab 4_8 - Hilfe anbieten': {
      'title': 'Hilfe anbieten',
      'phrases': [
        {'german': 'Wie kann ich dir helfen?', 'literal': 'How can I you help?', 'english': 'How can I help you?'},
        {'german': 'Was kann ich für dich tun?', 'literal': 'What can I for you do?', 'english': 'What can I do for you?'},
        {'german': 'Ist alles gut bei dir?', 'literal': 'Is all good by you?', 'english': 'Is everything alright with you?'},
      ],
    },
    'Tab 4_9 - um Hilfe bitten': {
      'title': 'um Hilfe bitten',
      'phrases': [
        {'german': 'Kannst du mir helfen?', 'literal': 'Can you me help?', 'english': 'Can you help me?'},
        {'german': 'Könnten Sie mir helfen?', 'literal': 'Could You me help?', 'english': 'Could you help me?'},
      ],
    },
    'Tab 4_10 - Orientierung und Verfügbarkeit': {
      'title': 'Orientierung und Verfügbarkeit',
      'phrases': [
        {'german': 'Wo ist/sind...?', 'literal': 'Where is/are...?', 'english': 'Where is/are...?'},
        {'german': 'Wo finde ich...?', 'literal': 'Where find I...?', 'english': 'Where do I find...?'},
        {'german': 'Haben Sie...?', 'literal': 'Have You...?', 'english': 'Do you have...?'},
        {'german': 'Gibt es hier...?', 'literal': 'Gives it here...?', 'english': 'Is/are there here...?'},
        {'german': 'Ich suche...', 'literal': 'I seek...', 'english': 'I am looking for...'},
        {'german': 'Wo kann ich...?', 'literal': 'Where can I...?', 'english': 'Where can I...?'},
      ],
    },
    'Tab 4_11 - Richtungsangaben': {
      'title': 'Richtungsangaben',
      'phrases': [
        {'german': '(Nach) links.', 'literal': '(Towards) left.', 'english': '(To the) left.'},
        {'german': '(Nach) rechts.', 'literal': '(Towards) right.', 'english': '(To the) right.'},
        {'german': 'Geradeaus.', 'literal': 'Straight-out.', 'english': 'Straight ahead.'},
      ],
    },
    'Tab 4_12 - Ortsangaben': {
      'title': 'Ortsangaben',
      'phrases': [
        {'german': 'Gleich hier.', 'literal': '[Right] here.', 'english': 'Right here.'},
        {'german': 'Dort drüben.', 'literal': 'There [over].', 'english': 'Over there.'},
        {'german': 'Da vorne/hinten.', 'literal': 'There [in the front/back].', 'english': 'Up there/back there.'},
      ],
    },
    'Tab 4_13 - Preis': {
      'title': 'Preis',
      'phrases': [
        {'german': 'Wie viel kostet...?', 'literal': 'How much costs...?', 'english': 'How much does... cost?'},
        {'german': 'Das kostet/das ist...', 'literal': 'That costs/that is...', 'english': 'That costs/that is...'},
      ],
    },
    'Tab 4_14 - kurze Bestätigung': {
      'title': 'Kurze Bestätigung',
      'phrases': [
        {'german': 'Perfekt.', 'literal': 'Perfect.', 'english': 'Perfect.'},
        {'german': 'Alles klar.', 'literal': 'All clear.', 'english': 'Got it.'},
        {'german': 'In Ordnung.', 'literal': 'In order.', 'english': 'All right.'},
      ],
    },
    'Tab 4_15 - kurze Bestätigung ugs': {
      'title': 'Kurze Bestätigung [ugs.]',
      'phrases': [
        {'german': 'Passt.', 'literal': 'Suits.', 'english': 'That works.'},
        {'german': 'Super.', 'literal': 'Super.', 'english': 'Great.'},
        {'german': 'Gut.', 'literal': 'Good.', 'english': 'Good.'},
      ],
    },
    'Tab 5_1 - Nach einem Tisch fragen': {
      'title': 'Nach einem Tisch fragen',
      'phrases': [
        {'german': 'Einen Tisch für...', 'literal': 'A table for...', 'english': 'A table for...'},
        {'german': 'Einen Tisch für zwei Personen, bitte.', 'literal': 'A table for two persons, please.', 'english': 'A table for two, please.'},
      ],
    },
    'Tab 5_2 - Tischreservierung': {
      'title': 'Tischreservierung',
      'phrases': [
        {'german': 'Haben Sie reserviert?', 'literal': 'Have you reserved?', 'english': 'Do you have a reservation?'},
        {'german': 'Ja/Nein, ich habe reserviert.', 'literal': 'Yes/No, I have reserved.', 'english': 'Yes/No, I have a reservation.'},
      ],
    },
    'Tab 5_3 - Bestellung aufnehmen': {
      'title': 'Bestellung aufnehmen',
      'phrases': [
        {'german': 'Was darf ich Ihnen bringen?', 'literal': 'What may I you bring?', 'english': 'What may I bring you?'},
        {'german': 'Was darf\'s denn sein?', 'literal': 'What may it then be?', 'english': 'What can I get you?'},
      ],
    },
    'Tab 5_4 - um ewas bitten und bestellen': {
      'title': 'Um etwas bitten und bestellen',
      'phrases': [
        {'german': 'Die Speisekarte, bitte.', 'literal': 'The dish-card, please.', 'english': 'The menu, please.'},
        {'german': 'Eine Cola, bitte.', 'literal': 'A cola, please.', 'english': 'A cola, please.'},
        {'german': 'Ich nehme..., bitte.', 'literal': 'I take..., please.', 'english': 'I take..., please.'},
        {'german': 'Ich hätte gerne...', 'literal': 'I would have gladly...', 'english': 'I\'d like to have...'},
      ],
    },
    'Tab 5_5 - bestellen-Alternative': {
      'title': 'Bestellen - Alternative',
      'phrases': [
        {'german': 'Einmal..., bitte.', 'literal': 'One-time..., please.', 'english': 'One..., please.'},
      ],
    },
    'Tab 5_6 - bestellen mit nonverbaler Ergänzung': {
      'title': 'Bestellen mit nonverbaler Ergänzung',
      'phrases': [
        {'german': 'Ich nehme das hier.', 'literal': 'I take this here.', 'english': 'I\'ll take this here.'},
        {'german': 'Ich hätte gerne das da.', 'literal': 'I would have gladly that there.', 'english': 'I\'d like to have that there.'},
      ],
    },
    'Tab 5_7 - weitere Bestellphrasen': {
      'title': 'Weitere Bestellphrasen',
      'phrases': [
        {'german': 'Noch etwas?', 'literal': 'Still something?', 'english': 'Anything else?'},
        {'german': 'Dann nehme ich auch...', 'literal': 'Then take I also...', 'english': 'I\'ll also have...'},
        {'german': 'Das ist alles.', 'literal': 'That is all.', 'english': 'That\'s all.'},
        {'german': 'Mahlzeit.', 'literal': 'Meal-time.', 'english': 'Enjoy your meal.'},
        {'german': 'Guten Appetit.', 'literal': 'Good appetite.', 'english': 'Enjoy your meal.'},
      ],
    },
    'Tab 5_8 - Spezifikationen - vor Ort oder zum Mitnehmen': {
      'title': 'Spezifikationen - vor Ort oder zum Mitnehmen',
      'phrases': [
        {'german': 'Zum Hieressen.', 'literal': 'To-the here-eating.', 'english': 'To eat here or to go?'},
        {'german': 'Zum Hieressen oder zum Mitnehmen?', 'literal': 'To-the here-eating or to-the take-with?', 'english': 'To eat here or to go?'},
        {'german': 'Zum Hiertrinken.', 'literal': 'To-the here-drinking.', 'english': 'To drink here.'},
        {'german': 'Für hier, bitte.', 'literal': 'For here, please.', 'english': 'For here, please.'},
      ],
    },
    'Tab 5_9 - Spezifikationen - Getränkezusätze': {
      'title': 'Spezifikationen - Getränkezusätze',
      'phrases': [
        {'german': 'Mit/ohne Milch.', 'literal': 'With/without milk.', 'english': 'With/without milk.'},
        {'german': 'Mit/ohne Kohlensäure.', 'literal': 'With/without carbonic acid.', 'english': 'With/without carbonation.'},
        {'german': 'Mit/ohne Fruchtgeschmack.', 'literal': 'With/without fruit taste.', 'english': 'With/without fruit flavor.'},
      ],
    },
    'Tab 5_10 - Wasserarten': {
      'title': 'Wasserarten',
      'phrases': [
        {'german': 'Ein stilles Wasser, bitte.', 'literal': 'A still water, please.', 'english': 'A still water, please.'},
        {'german': 'Leitungswasser, bitte.', 'literal': 'Conduit-water, please.', 'english': 'Tap water, please.'},
        {'german': 'Ein Mineralwasser.', 'literal': 'A mineral-water.', 'english': 'A soda water.'},
      ],
    },
    'Tab 5_11 - Alkoholische Getränke': {
      'title': 'Alkoholische Getränke',
      'phrases': [
        {'german': 'Ein großes/kleines Bier.', 'literal': 'A big/small beer.', 'english': 'A large/small beer.'},
        {'german': 'Einen Rotwein/Weißwein.', 'literal': 'A red-wine/white-wine.', 'english': 'A red/white wine.'},
      ],
    },
    'Tab 5_12 - Bezahlprozess': {
      'title': 'Bezahlprozess',
      'phrases': [
        {'german': 'Die Rechnung, bitte.', 'literal': 'The calculation, please.', 'english': 'The bill, please.'},
        {'german': 'Zahlen, bitte.', 'literal': 'Pay, please.', 'english': 'Can I pay, please?'},
        {'german': 'Zusammen oder getrennt?', 'literal': 'Together or separated?', 'english': 'Together or separate?'},
        {'german': 'Zusammen/getrennt.', 'literal': 'Together/separated.', 'english': 'Together/separate.'},
        {'german': 'In bar oder mit Karte?', 'literal': 'In cash or with card?', 'english': 'Cash or card?'},
        {'german': 'Mit Karte, bitte.', 'literal': 'With card, please.', 'english': 'Card, please.'},
        {'german': 'In bar, bitte.', 'literal': 'In cash, please.', 'english': 'Cash, please.'},
        {'german': 'Das macht... Euro.', 'literal': 'That makes... Euro.', 'english': 'That\'ll be... Euro.'},
      ],
    },
    'Tab 5_13 - Trinkgeld geben': {
      'title': 'Trinkgeld geben',
      'phrases': [
        {'german': 'Stimmt so.', 'literal': '[Is correct] so.', 'english': 'Keep the change.'},
        {'german': 'Machen wir/du... Euro.', 'literal': 'Make we/you... Euro.', 'english': 'Round it up to... Euro.'},
        {'german': 'Das ist für Sie.', 'literal': 'This is for You.', 'english': 'This is for you.'},
        {'german': 'Kann ich auch Trinkgeld geben?', 'literal': 'Can I also tip give?', 'english': 'Can I leave a tip?'},
      ],
    },
    'Tab 5_14 - Quittung': {
      'title': 'Quittung',
      'phrases': [
        {'german': 'Brauchen Sie eine Quittung?', 'literal': 'Need you a receipt?', 'english': 'Do you need a receipt?'},
        {'german': 'Ich brauche keine Quittung.', 'literal': 'I need no receipt.', 'english': 'I don\'t need a receipt.'},
        {'german': 'Ich brauche eine Quittung.', 'literal': 'I need a receipt.', 'english': 'I need a receipt.'},
      ],
    },
    'Tab 5_15 - sich höflich bedanken': {
      'title': 'Sich höflich bedanken',
      'phrases': [
        {'german': 'Bitte, danke.', 'literal': 'Please, thank you.', 'english': 'Please, thank you.'},
        {'german': 'Sehr freundlich von Ihnen.', 'literal': 'Very friendly of you.', 'english': 'That\'s very kind of you.'},
      ],
    },
    'Tab 5_16 - Toilette': {
      'title': 'Toilette',
      'phrases': [
        {'german': 'Wo ist die Toilette?', 'literal': 'Where is the toilet?', 'english': 'Where is the toilet?'},
        {'german': 'Ich muss auf die Toilette.', 'literal': 'I must on(to) the toilet.', 'english': 'I need to go to the toilet.'},
      ],
    },
    'Tab 5_17 - sich entschuldigen': {
      'title': 'Sich entschuldigen',
      'phrases': [
        {'german': 'Ich muss mich entschuldigen.', 'literal': 'I must myself excuse.', 'english': 'Please excuse me.'},
      ],
    },
    'Tab 5_18 - telefonisch Essen bestellen': {
      'title': 'Telefonisch Essen bestellen',
      'phrases': [
        {'german': 'Ich möchte Essen bestellen.', 'literal': 'I would like food order.', 'english': 'I\'d like to order food.'},
        {'german': 'Zum Zustellen oder zum Abholen?', 'literal': 'To-the deliver or to-the pick-up?', 'english': 'For delivery or pickup?'},
      ],
    },
    'Tab 5_19 - telefonisch Essen bestellen - Adresse angeben': {
      'title': 'Telefonisch Essen bestellen - Adresse angeben',
      'phrases': [
        {'german': 'Meine Adresse ist...', 'literal': 'My address is...', 'english': 'My address is...'},
        {'german': 'Das ist in der... Straße.', 'literal': 'That is in the... street.', 'english': 'That\'s in... street.'},
      ],
    },
    'Tab 5_20 - telefonisch Essen bestellen - Rückfragen und Hinweise': {
      'title': 'Telefonisch Essen bestellen - Rückfragen und Hinweise',
      'phrases': [
        {'german': 'Liefern Sie auch?', 'literal': 'Deliver you also?', 'english': 'Do you deliver?'},
        {'german': 'Wie lange wird es dauern?', 'literal': 'How long will it take?', 'english': 'How long will it take?'},
        {'german': 'Bitte klingeln Sie an der Tür.', 'literal': 'Please ring you at the door.', 'english': 'Please ring at the door.'},
      ],
    },
    'Tab 6_1 - Verkehrsmittel - Ich nehme': {
      'title': 'Verkehrsmittel - Ich nehme',
      'phrases': [
        {'german': 'Ich nehme...', 'literal': 'I take...', 'english': 'I\'m taking...'},
        {'german': '... den Bus.', 'literal': '... the bus.', 'english': '... the bus.'},
        {'german': '... den Zug.', 'literal': '... the train.', 'english': '... the train.'},
        {'german': '... das Fahrrad.', 'literal': '... the bike.', 'english': '... the bike.'},
        {'german': '... das Auto.', 'literal': '... the car.', 'english': '... the car.'},
        {'german': '... die Straßenbahn.', 'literal': '... the tram.', 'english': '... the tram.'},
        {'german': '... die U-Bahn.', 'literal': '... the metro.', 'english': '... the metro.'},
        {'german': '... ein Taxi.', 'literal': '... a taxi.', 'english': '... a taxi.'},
      ],
    },
    'Tab 6_2 - Verkehrsmittel - Ich fahre mit': {
      'title': 'Verkehrsmittel - Ich fahre mit',
      'phrases': [
        {'german': 'Ich fahre mit...', 'literal': 'I drive with...', 'english': 'I\'m going by...'},
        {'german': '... dem Bus.', 'literal': '... the bus.', 'english': '... the bus.'},
        {'german': '... dem Zug.', 'literal': '... the train.', 'english': '... the train.'},
        {'german': '... dem Fahrrad.', 'literal': '... the bike.', 'english': '... the bike.'},
        {'german': '... dem Auto.', 'literal': '... the car.', 'english': '... the car.'},
        {'german': '... der Straßenbahn.', 'literal': '... the tram.', 'english': '... the tram.'},
        {'german': '... der U-Bahn.', 'literal': '... the metro.', 'english': '... the metro.'},
        {'german': '... einem Taxi.', 'literal': '... a taxi.', 'english': '... a taxi.'},
      ],
    },
    'Tab 6_3 - Verkehrsmittel - zu Fuß und mit dem Flugzeug': {
      'title': 'Verkehrsmittel - zu Fuß und mit dem Flugzeug',
      'phrases': [
        {'german': 'Ich gehe zu Fuß.', 'literal': 'I go to foot.', 'english': 'I\'m going on foot.'},
        {'german': 'Ich fliege mit dem Flugzeug.', 'literal': 'I fly with the airplane.', 'english': 'I\'m flying.'},
      ],
    },
    'Tab 6_4 - Orientierung und Ticketkauf': {
      'title': 'Orientierung und Ticketkauf',
      'phrases': [
        {'german': 'Wie komme ich zu...?', 'literal': 'How come I to...?', 'english': 'How do I get to...?'},
        {'german': 'Eine Fahrkarte nach...', 'literal': 'A drive-card to...', 'english': 'A ticket to...'},
        {'german': 'Ich muss vorher...', 'literal': 'I must before...', 'english': 'I have to go first...'},
      ],
    },
    'Tab 6_5 - richtiges Verkehrsmittel finden': {
      'title': 'Richtiges Verkehrsmittel finden',
      'phrases': [
        {'german': 'Ist das der richtige Weg?', 'literal': 'Is this the right way?', 'english': 'Is this the right way?'},
        {'german': 'Fährt der Zug nach...?', 'literal': 'Drives the train to...?', 'english': 'Does the train go to...?'},
        {'german': 'Fährt der Bus nach...?', 'literal': 'Drives the bus to...?', 'english': 'Does the bus go to...?'},
      ],
    },
    'Tab 6_6 - Ziel angeben': {
      'title': 'Ziel angeben',
      'phrases': [
        {'german': 'Wohin muss ich?', 'literal': 'Where-to must I?', 'english': 'Where do I need to go?'},
        {'german': 'Ich muss/möchte nach...', 'literal': 'I must/would like to...', 'english': 'I have/want to go to...'},
        {'german': 'Ins Stadtzentrum.', 'literal': 'In-the city-center.', 'english': 'To the city center.'},
        {'german': 'Zum Bahnhof.', 'literal': 'To-the train station.', 'english': 'To the train station.'},
        {'german': 'Nach Berlin, bitte.', 'literal': 'To Berlin, please.', 'english': 'To Berlin, please.'},
      ],
    },
    'Tab 6_7 - um Auskunft bitten': {
      'title': 'Um Auskunft bitten',
      'phrases': [
        {'german': 'Auf welchem Gleis?', 'literal': 'On which platform?', 'english': 'On which platform?'},
        {'german': 'Gibt es hier in der Nähe...?', 'literal': 'Gives it here in the near...?', 'english': 'Is there a... nearby?'},
        {'german': 'Ist das weit von hier?', 'literal': 'Is that far from here?', 'english': 'Is that far from here?'},
        {'german': 'Wie komme ich am besten zu...?', 'literal': 'How come I best to...?', 'english': 'What\'s the best way to get to...?'},
        {'german': 'Gibt es eine direkte Verbindung?', 'literal': 'Gives it a direct connection?', 'english': 'Is there a direct connection?'},
      ],
    },
    'Tab 6_8 - Verbindung und Umstieg': {
      'title': 'Verbindung und Umstieg',
      'phrases': [
        {'german': 'Du musst die Verbindung nehmen.', 'literal': 'You must the connection take.', 'english': 'You have to take the connection.'},
        {'german': 'Sie müssen umsteigen.', 'literal': 'You must transfer.', 'english': 'You have to transfer.'},
        {'german': 'Du musst einmal umsteigen.', 'literal': 'You must once transfer.', 'english': 'You have to transfer once.'},
        {'german': 'Sie müssen einmal umsteigen.', 'literal': 'You must once transfer.', 'english': 'You have to transfer once.'},
        {'german': 'Es gibt eine direkte Verbindung.', 'literal': 'It gives a direct connection.', 'english': 'There is a direct connection.'},
        {'german': 'Es gibt keine direkte Verbindung.', 'literal': 'It gives no direct connection.', 'english': 'There is no direct connection.'},
      ],
    },
    'Tab 6_9 - Abfahrt und Ankunft': {
      'title': 'Abfahrt und Ankunft',
      'phrases': [
        {'german': 'Wann kommt...?', 'literal': 'When comes...?', 'english': 'When does... come?'},
        {'german': 'Wann fährt...?', 'literal': 'When drives...?', 'english': 'When does... leave?'},
        {'german': 'Der Zug/Bus kommt um...', 'literal': 'The train/bus comes at...', 'english': 'The train/bus arrives at...'},
        {'german': 'Der Zug/Bus fährt um...', 'literal': 'The train/bus drives at...', 'english': 'The train/bus leaves at...'},
        {'german': 'Das Flugzeug startet um...', 'literal': 'The airplane starts at...', 'english': 'The plane takes off at...'},
        {'german': 'Das Flugzeug landet um...', 'literal': 'The airplane lands at...', 'english': 'The plane lands at...'},
      ],
    },
    'Tab 6_10 - Verspätung und Ausfall': {
      'title': 'Verspätung und Ausfall',
      'phrases': [
        {'german': 'Der Zug/Bus ist verspätet.', 'literal': 'The train/bus is delayed.', 'english': 'The train/bus is delayed.'},
        {'german': 'Der Zug/Bus ist nicht pünktlich.', 'literal': 'The train/bus is not punctual.', 'english': 'The train/bus is not on time.'},
        {'german': 'Der Flug ist gestrichen.', 'literal': 'The flight is cancelled.', 'english': 'The flight is cancelled.'},
        {'german': 'Ich habe den Zug verpasst.', 'literal': 'I have the train missed.', 'english': 'I missed the train.'},
      ],
    },
    'Tab 6_11 - Ankunftszeit und Verspätung': {
      'title': 'Ankunftszeit und Verspätung',
      'phrases': [
        {'german': 'Wann kommen Sie an?', 'literal': 'When come you at?', 'english': 'When are you arriving?'},
        {'german': 'Wann kommst du an?', 'literal': 'When come you at?', 'english': 'When are you arriving?'},
        {'german': 'Ich werde um... Uhr da sein.', 'literal': 'I will at... o\'clock there be.', 'english': 'I will be there at... o\'clock.'},
        {'german': 'Ich komme um... Uhr an.', 'literal': 'I come at... o\'clock at.', 'english': 'I arrive at... o\'clock.'},
        {'german': 'Ich verspäte mich.', 'literal': 'I delay myself.', 'english': 'I am running late.'},
      ],
    },
    'Tab 6_12 - Zimmer buchen': {
      'title': 'Zimmer buchen',
      'phrases': [
        {'german': 'Ich möchte ein Zimmer buchen.', 'literal': 'I would like a room book.', 'english': 'I\'d like to book a room.'},
        {'german': 'Ich habe ein Zimmer gebucht.', 'literal': 'I have a room booked.', 'english': 'I\'ve booked a room.'},
        {'german': 'Für eine Nacht.', 'literal': 'For one night.', 'english': 'For one night.'},
        {'german': 'Für zwei/drei Nächte.', 'literal': 'For two/three nights.', 'english': 'For two/three nights.'},
      ],
    },
    'Tab 7_1 - Diskursmarker': {
      'title': 'Diskursmarker',
      'phrases': [
        {'german': 'Also, ...', 'literal': 'So, ...', 'english': 'So, ... / Well the'},
        {'german': 'Na ja, ...', 'literal': 'Well, ...', 'english': 'Well, ...'},
        {'german': 'Tja, ...', 'literal': 'Well, ...', 'english': 'Well, ... / Tough'},
        {'german': 'Gut, ...', 'literal': 'Well, ...', 'english': 'Well, ... / Alright'},
        {'german': 'Okay, ...', 'literal': 'Okay, ...', 'english': 'Okay, ...'},
        {'german': 'Na gut, ...', 'literal': 'Na good, ...', 'english': 'Well, alright,'},
      ],
    },
    'Tab 7_2 - Pausenfüller': {
      'title': 'Pausenfüller',
      'phrases': [
        {'german': 'Ähm ...', 'literal': 'Um ...', 'english': 'Um ...'},
        {'german': 'Hm ...', 'literal': 'Um ...', 'english': 'Um ...'},
        {'german': 'Gute Frage.', 'literal': 'Good question.', 'english': 'Good question.'},
        {'german': 'Ich weiß nicht.', 'literal': 'I know not.', 'english': 'I don\'t know.'},
        {'german': 'Lass mich (kurz) überlegen.', 'literal': 'Let me (short) think.', 'english': 'Let me think.'},
        {'german': 'Lassen Sie mich (kurz) überlegen.', 'literal': 'Let You me (short) think.', 'english': 'Let me think.'},
        {'german': 'Ich habe das Wort vergessen.', 'literal': 'I have the word forgotten.', 'english': 'I forgot the word.'},
        {'german': 'Wie sagt man das auf Deutsch?', 'literal': 'How says one that on German?', 'english': 'How do you say that in German?'},
      ],
    },
    'Tab 7_3 - Verständnissicherung': {
      'title': 'Verständnissicherung',
      'phrases': [
        {'german': 'Weißt du, was ich meine?', 'literal': 'Know you, what I mean?', 'english': 'Do you know what I mean?'},
        {'german': 'Wissen Sie, was ich meine?', 'literal': 'Know You, what I mean?', 'english': 'Do you know what I mean?'},
        {'german': 'Verstehst du das?', 'literal': 'Understand you that?', 'english': 'Do you understand that?'},
        {'german': 'Verstehen Sie das?', 'literal': 'Understand You that?', 'english': 'Do you understand that?'},
      ],
    },
    'Tab 7_4 - Rückversicherung': {
      'title': 'Rückversicherung',
      'phrases': [
        {'german': 'Ist das richtig?', 'literal': 'Is that right?', 'english': 'Is that correct?'},
        {'german': 'Sagt man das so?', 'literal': 'Says one that so?', 'english': 'Is that how you say it?'},
        {'german': 'Gibt es das Wort?', 'literal': 'Gives it this word?', 'english': 'Does this word exist?'},
        {'german': 'Ich meine...', 'literal': 'I mean...', 'english': 'I mean...'},
      ],
    },
    'Tab 7_5 - Unwissenheit ausdrücken': {
      'title': 'Unwissenheit ausdrücken',
      'phrases': [
        {'german': 'Keine Ahnung.', 'literal': 'No hunch.', 'english': 'No clue.'},
        {'german': 'Keine Idee.', 'literal': 'No idea.', 'english': 'No idea.'},
        {'german': 'Keinen Plan.', 'literal': 'No plan.', 'english': 'No plan.'},
      ],
    },
    'Tab 7_6 - Unwissenheit ausdrücken - Alternativen': {
      'title': 'Unwissenheit ausdrücken - Alternativen',
      'phrases': [
        {'german': 'Ich weiß (es) nicht.', 'literal': 'I know (it) not.', 'english': 'I don\'t know.'},
        {'german': 'Ich erinnere mich nicht.', 'literal': 'I remind myself not.', 'english': 'I don\'t remember.'},
        {'german': 'Es fällt mir (gerade) nicht ein.', 'literal': 'It falls me (just) not in.', 'english': 'It doesn\'t come to mind (right now).'},
        {'german': 'Es kommt darauf an.', 'literal': 'It [arrives] thereupon.', 'english': 'It depends.'},
      ],
    },
    'Tab 7_7 - Bestätigungsfragen': {
      'title': 'Bestätigungsfragen',
      'phrases': [
        {'german': 'Ich kann mit Karte zahlen, oder?', 'literal': 'I can with card pay, or?', 'english': 'I can pay by card, right?'},
        {'german': 'Sie sind auch aus Deutschland, oder?', 'literal': 'You are also from Germany, or?', 'english': 'You\'re not from Germany, are you?'},
      ],
    },
    'Tab 7_8 - Bestätigung und Zustimmung': {
      'title': 'Bestätigung und Zustimmung',
      'phrases': [
        {'german': 'Genau.', 'literal': 'Exact.', 'english': 'Exactly.'},
        {'german': 'Korrekt.', 'literal': 'Correct.', 'english': 'Correct.'},
        {'german': 'Richtig.', 'literal': 'Right.', 'english': 'Right.'},
      ],
    },
    'Tab 7_9 - Verneinung und Korrektur': {
      'title': 'Verneinung und Korrektur',
      'phrases': [
        {'german': 'Nicht ganz.', 'literal': 'Not whole.', 'english': 'Not fully/quite.'},
        {'german': 'Nicht direkt.', 'literal': 'Not direct.', 'english': 'Not directly/exactly.'},
      ],
    },
    'Tab 8_1 - Warnhinweise': {
      'title': 'Warnhinweise',
      'phrases': [
        {'german': 'Achtung!', 'literal': 'Attention!', 'english': 'Attention!'},
        {'german': 'Vorsicht!', 'literal': 'Caution!', 'english': 'Be careful!'},
        {'german': 'Gefahr!', 'literal': 'Danger!', 'english': 'Danger!'},
        {'german': 'Passen Sie auf!', 'literal': 'Pass you on!', 'english': 'Watch out!'},
      ],
    },
    'Tab 8_2 - Warnrufe': {
      'title': 'Warnrufe',
      'phrases': [
        {'german': 'Hilfe!', 'literal': 'Help!', 'english': 'Help!'},
        {'german': 'Feuer!', 'literal': 'Fire!', 'english': 'Fire!'},
        {'german': 'Polizei!', 'literal': 'Police!', 'english': 'Police!'},
        {'german': 'Krankenwagen!', 'literal': 'Ambulance!', 'english': 'Ambulance!'},
      ],
    },
    'Tab 8_3 - Hilfe rufen': {
      'title': 'Hilfe rufen',
      'phrases': [
        {'german': 'Können Sie mir helfen?', 'literal': 'Can you me help?', 'english': 'Can you help me?'},
        {'german': 'Ich brauche Hilfe.', 'literal': 'I need help.', 'english': 'I need help.'},
        {'german': 'Bitte helfen Sie mir!', 'literal': 'Please help you me!', 'english': 'Please help me!'},
      ],
    },
    'Tab 8_4 - Hilfe anbieten': {
      'title': 'Hilfe anbieten',
      'phrases': [
        {'german': 'Kann ich Ihnen helfen?', 'literal': 'Can I you help?', 'english': 'Can I help you?'},
        {'german': 'Brauchen Sie Hilfe?', 'literal': 'Need you help?', 'english': 'Do you need help?'},
        {'german': 'Soll ich Ihnen helfen?', 'literal': 'Should I you help?', 'english': 'Should I help you?'},
      ],
    },
    'Tab 8_5 - auf Hilfsangebote reagieren': {
      'title': 'Auf Hilfsangebote reagieren',
      'phrases': [
        {'german': 'Ja, bitte.', 'literal': 'Yes, please.', 'english': 'Yes, please.'},
        {'german': 'Nein, danke.', 'literal': 'No, thank you.', 'english': 'No, thank you.'},
        {'german': 'Das wäre sehr nett.', 'literal': 'That would be very nice.', 'english': 'That would be very kind.'},
      ],
    },
    'Tab 8_6 - um Auskunft bitten': {
      'title': 'Um Auskunft bitten',
      'phrases': [
        {'german': 'Wo ist...?', 'literal': 'Where is...?', 'english': 'Where is...?'},
        {'german': 'Können Sie mir sagen, wo... ist?', 'literal': 'Can you me say, where... is?', 'english': 'Can you tell me where... is?'},
        {'german': 'Ich suche...', 'literal': 'I seek...', 'english': 'I\'m looking for...'},
      ],
    },
    'Tab 8_7 - um Auskunft bitten - Gibt es hier': {
      'title': 'Um Auskunft bitten - Gibt es hier',
      'phrases': [
        {'german': 'Gibt es hier...?', 'literal': 'Gives it here...?', 'english': 'Is there a... here?'},
        {'german': 'Gibt es hier in der Nähe...?', 'literal': 'Gives it here in the near...?', 'english': 'Is there a... nearby?'},
        {'german': 'Wo ist das nächste...?', 'literal': 'Where is the next...?', 'english': 'Where is the nearest...?'},
      ],
    },
    'Tab 8_8 - keine Auskunft': {
      'title': 'Keine Auskunft',
      'phrases': [
        {'german': 'Das weiß ich nicht.', 'literal': 'That know I not.', 'english': 'I don\'t know that.'},
        {'german': 'Ich kann Ihnen nicht helfen.', 'literal': 'I can you not help.', 'english': 'I can\'t help you.'},
        {'german': 'Entschuldigung, ich weiß es nicht.', 'literal': 'Excuse me, I know it not.', 'english': 'Sorry, I don\'t know.'},
      ],
    },
    'Tab 8_9 - auf keine Auskunft reagieren': {
      'title': 'Auf keine Auskunft reagieren',
      'phrases': [
        {'german': 'Das ist in Ordnung.', 'literal': 'That is in order.', 'english': 'That\'s okay.'},
        {'german': 'Kein Problem.', 'literal': 'No problem.', 'english': 'No problem.'},
        {'german': 'Danke trotzdem.', 'literal': 'Thank you nevertheless.', 'english': 'Thanks anyway.'},
      ],
    },
    'Tab 8_10 - Handy aufladen': {
      'title': 'Handy aufladen',
      'phrases': [
        {'german': 'Mein Handy ist leer.', 'literal': 'My mobile is empty.', 'english': 'My phone is dead.'},
        {'german': 'Ich muss mein Handy aufladen.', 'literal': 'I must my mobile charge.', 'english': 'I need to charge my phone.'},
        {'german': 'Kann ich mein Handy hier aufladen?', 'literal': 'Can I my mobile here charge?', 'english': 'Can I charge my phone here?'},
      ],
    },
    'Tab 8_11 - Telefon benutzen': {
      'title': 'Telefon benutzen',
      'phrases': [
        {'german': 'Kann ich Ihr Telefon benutzen?', 'literal': 'Can I your telephone use?', 'english': 'Can I use your phone?'},
        {'german': 'Gibt es hier ein Telefon?', 'literal': 'Gives it here a telephone?', 'english': 'Is there a phone here?'},
        {'german': 'Wo kann ich telefonieren?', 'literal': 'Where can I telephone?', 'english': 'Where can I make a call?'},
      ],
    },
    'Tab 8_12 - Akku leer': {
      'title': 'Akku leer',
      'phrases': [
        {'german': 'Mein Akku ist leer.', 'literal': 'My battery is empty.', 'english': 'My battery is dead.'},
        {'german': 'Ich habe keinen Strom mehr.', 'literal': 'I have no current more.', 'english': 'I have no power left.'},
        {'german': 'Mein Handy geht nicht mehr.', 'literal': 'My mobile goes not more.', 'english': 'My phone doesn\'t work anymore.'},
      ],
    },
    'Tab 8_13 - Verlust melden': {
      'title': 'Verlust melden',
      'phrases': [
        {'german': 'Ich habe etwas verloren.', 'literal': 'I have something lost.', 'english': 'I lost something.'},
        {'german': 'Wo ist das Fundbüro?', 'literal': 'Where is the lost property office?', 'english': 'Where is the lost and found?'},
        {'german': 'Ich muss einen Verlust melden.', 'literal': 'I must a loss report.', 'english': 'I need to report a loss.'},
      ],
    },
    'Tab 8_14 - Verlust melden - Alternative 1': {
      'title': 'Verlust melden - Alternative 1',
      'phrases': [
        {'german': 'Meine Tasche ist weg.', 'literal': 'My bag is away.', 'english': 'My bag is gone.'},
        {'german': 'Ich kann meine Tasche nicht finden.', 'literal': 'I can my bag not find.', 'english': 'I can\'t find my bag.'},
        {'german': 'Haben Sie meine Tasche gesehen?', 'literal': 'Have you my bag seen?', 'english': 'Have you seen my bag?'},
      ],
    },
    'Tab 8_15 - Verlust melden - Alternative 2': {
      'title': 'Verlust melden - Alternative 2',
      'phrases': [
        {'german': 'Mein Pass ist weg.', 'literal': 'My passport is away.', 'english': 'My passport is gone.'},
        {'german': 'Ich habe meinen Pass verloren.', 'literal': 'I have my passport lost.', 'english': 'I lost my passport.'},
        {'german': 'Was soll ich tun?', 'literal': 'What should I do?', 'english': 'What should I do?'},
      ],
    },
    'Tab 8_16 - Diebstahl melden': {
      'title': 'Diebstahl melden',
      'phrases': [
        {'german': 'Ich wurde bestohlen.', 'literal': 'I was stolen.', 'english': 'I was robbed.'},
        {'german': 'Jemand hat mir etwas gestohlen.', 'literal': 'Someone has me something stolen.', 'english': 'Someone stole something from me.'},
        {'german': 'Ich muss einen Diebstahl melden.', 'literal': 'I must a theft report.', 'english': 'I need to report a theft.'},
      ],
    },
    'Tab 8_17 - Überforderung ausdrücken': {
      'title': 'Überforderung ausdrücken',
      'phrases': [
        {'german': 'Ich verstehe das nicht.', 'literal': 'I understand that not.', 'english': 'I don\'t understand this.'},
        {'german': 'Das ist zu kompliziert.', 'literal': 'That is too complicated.', 'english': 'This is too complicated.'},
        {'german': 'Ich bin überfordert.', 'literal': 'I am overwhelmed.', 'english': 'I\'m overwhelmed.'},
      ],
    },
    'Tab 8_18 - Notruf veranlassen': {
      'title': 'Notruf veranlassen',
      'phrases': [
        {'german': 'Rufen Sie einen Krankenwagen!', 'literal': 'Call you an ambulance!', 'english': 'Call an ambulance!'},
        {'german': 'Rufen Sie die Polizei!', 'literal': 'Call you the police!', 'english': 'Call the police!'},
        {'german': 'Rufen Sie die Feuerwehr!', 'literal': 'Call you the fire brigade!', 'english': 'Call the fire department!'},
      ],
    },
    'Tab 8_19 - Notrufnummern im DACH-Raum': {
      'title': 'Notrufnummern im DACH-Raum',
      'phrases': [
        {'german': 'Polizei: 110', 'literal': 'Police: 110', 'english': 'Police: 110'},
        {'german': 'Feuerwehr: 112', 'literal': 'Fire brigade: 112', 'english': 'Fire department: 112'},
        {'german': 'Krankenwagen: 112', 'literal': 'Ambulance: 112', 'english': 'Ambulance: 112'},
      ],
    },
    'Tab 8_20 - Euronotrufnummer': {
      'title': 'Euronotrufnummer',
      'phrases': [
        {'german': 'Euronotruf: 112', 'literal': 'Euro emergency: 112', 'english': 'Euro emergency: 112'},
        {'german': 'Diese Nummer funktioniert überall in Europa.', 'literal': 'This number works everywhere in Europe.', 'english': 'This number works everywhere in Europe.'},
      ],
    },
    'Tab 9_1 - Wohnadresse und Kontaktdaten': {
      'title': 'Wohnadresse und Kontaktdaten',
      'phrases': [
        {'german': 'Was ist deine Adresse?', 'literal': 'What is your address?', 'english': 'What is your address?'},
        {'german': 'Wie ist deine Adresse?', 'literal': 'How is your address?', 'english': 'What is your address?'},
        {'german': 'Wo wohnst du?', 'literal': 'Where live you?', 'english': 'Where do you live?'},
        {'german': 'Kann ich deine Adresse haben?', 'literal': 'Can I your address have?', 'english': 'Can I have your address?'},
      ],
    },
    'Tab 9_2 - Wohnadresse und Kontaktdaten - Alternative': {
      'title': 'Wohnadresse und Kontaktdaten - Alternative',
      'phrases': [
        {'german': 'Wie lautet Ihre Adresse?', 'literal': 'How [is] your address?', 'english': 'What is your address?'},
        {'german': 'Meine Adresse ist...', 'literal': 'My address is...', 'english': 'My address is...'},
      ],
    },
    'Tab 9_3 - Geburtsdatum': {
      'title': 'Geburtsdatum',
      'phrases': [
        {'german': 'Wann bist du geboren?', 'literal': 'When are you born?', 'english': 'When were you born?'},
        {'german': 'Ich bin am... geboren.', 'literal': 'I am at-the... born.', 'english': 'I was born on...'},
        {'german': 'Was ist dein Geburtsdatum?', 'literal': 'What is your birth-date?', 'english': 'What is your date of birth?'},
        {'german': 'Mein Geburtsdatum ist...', 'literal': 'My birth-date is...', 'english': 'My date of birth is...'},
        {'german': 'In welchem Jahr bist du geboren?', 'literal': 'In which year are you born?', 'english': 'In which year were you born?'},
        {'german': 'Ich bin 1982 geboren.', 'literal': 'I am 1982 born.', 'english': 'I was born in 1982.'},
      ],
    },
    'Tab 9_4 - Geburtstag': {
      'title': 'Geburtstag',
      'phrases': [
        {'german': 'Wann hast du Geburtstag?', 'literal': 'When have you birthday?', 'english': 'When is your birthday?'},
        {'german': 'Ich habe am... Geburtstag.', 'literal': 'I have at-the... birthday.', 'english': 'My birthday is on...'},
      ],
    },
    'Tab 9_5 - Familienstand': {
      'title': 'Familienstand',
      'phrases': [
        {'german': 'Bist du verheiratet?', 'literal': 'Are you married?', 'english': 'Are you married?'},
        {'german': 'Sind Sie verheiratet?', 'literal': 'Are you married?', 'english': 'Are you married?'},
        {'german': 'Ich bin (nicht) verheiratet.', 'literal': 'I am (not) married.', 'english': 'I am (not) married.'},
        {'german': 'Ich bin ledig.', 'literal': 'I am single.', 'english': 'I am single.'},
        {'german': 'Ich bin verlobt.', 'literal': 'I am engaged.', 'english': 'I am engaged.'},
      ],
    },
    'Tab 9_6 - Kinder': {
      'title': 'Kinder',
      'phrases': [
        {'german': 'Hast du Kinder?', 'literal': 'Have you children?', 'english': 'Do you have children?'},
        {'german': 'Haben Sie Kinder?', 'literal': 'Have you children?', 'english': 'Do you have children?'},
        {'german': 'Ich habe (keine) Kinder.', 'literal': 'I have (no) children.', 'english': 'I have (no) children.'},
        {'german': 'Ich habe einen Sohn.', 'literal': 'I have a son.', 'english': 'I have a son.'},
        {'german': 'Ich habe eine Tochter.', 'literal': 'I have a daughter.', 'english': 'I have a daughter.'},
        {'german': 'Ich habe zwei Kinder.', 'literal': 'I have two children.', 'english': 'I have two children.'},
      ],
    },
    'Tab 9_7 - Geschwister': {
      'title': 'Geschwister',
      'phrases': [
        {'german': 'Hast du Geschwister?', 'literal': 'Have you siblings?', 'english': 'Do you have siblings?'},
        {'german': 'Haben Sie Geschwister?', 'literal': 'Have you siblings?', 'english': 'Do you have siblings?'},
        {'german': 'Ich habe (keine) Geschwister.', 'literal': 'I have (no) siblings.', 'english': 'I have (no) siblings.'},
        {'german': 'Ich habe einen Bruder.', 'literal': 'I have a brother.', 'english': 'I have a brother.'},
        {'german': 'Ich habe eine Schwester.', 'literal': 'I have a sister.', 'english': 'I have a sister.'},
        {'german': 'Ich habe zwei Brüder.', 'literal': 'I have two brothers.', 'english': 'I have two brothers.'},
      ],
    },
    'Tab 9_8 - Haustiere': {
      'title': 'Haustiere',
      'phrases': [
        {'german': 'Hast du Haustiere?', 'literal': 'Have you pets?', 'english': 'Do you have pets?'},
        {'german': 'Haben Sie Haustiere?', 'literal': 'Have you pets?', 'english': 'Do you have pets?'},
        {'german': 'Ich habe (keine) Haustiere.', 'literal': 'I have (no) pets.', 'english': 'I have (no) pets.'},
        {'german': 'Ich habe einen Hund.', 'literal': 'I have a dog.', 'english': 'I have a dog.'},
        {'german': 'Ich habe eine Katze.', 'literal': 'I have a cat.', 'english': 'I have a cat.'},
      ],
    },
    'Tab 11_1 - Aufenthaltsdauer': {
      'title': 'Aufenthaltsdauer',
      'phrases': [
        {'german': 'Wie lange bist du hier?', 'literal': 'How long are you here?', 'english': 'How long have you been here?'},
        {'german': 'Wie lange sind Sie hier?', 'literal': 'How long are you here?', 'english': 'How long have you been here?'},
        {'german': 'Ich bin seit einem Monat hier.', 'literal': 'I am since a month here.', 'english': 'I have been here for a month.'},
        {'german': 'Ich bin seit einer Woche hier.', 'literal': 'I am since a week here.', 'english': 'I have been here for a week.'},
      ],
    },
    'Tab 11_2 - Aufenthaltsdauer - regionale Variante': {
      'title': 'Aufenthaltsdauer - regionale Variante',
      'phrases': [
        {'german': 'Wie lange bist du schon hier?', 'literal': 'How long are you already here?', 'english': 'How long have you been here?'},
        {'german': 'Wie lange sind Sie schon hier?', 'literal': 'How long are you already here?', 'english': 'How long have you been here?'},
        {'german': 'Ich bin schon seit einem Monat hier.', 'literal': 'I am already since a month here.', 'english': 'I have been here for a month already.'},
      ],
    },
    'Tab 11_3 - Geplanter Aufenthalt': {
      'title': 'Geplanter Aufenthalt',
      'phrases': [
        {'german': 'Wie lange bleibst du?', 'literal': 'How long stay you?', 'english': 'How long are you staying?'},
        {'german': 'Wie lange bleiben Sie?', 'literal': 'How long stay you?', 'english': 'How long are you staying?'},
        {'german': 'Ich bleibe noch eine Woche.', 'literal': 'I stay still a week.', 'english': 'I am staying for another week.'},
        {'german': 'Ich bleibe noch zwei Wochen.', 'literal': 'I stay still two weeks.', 'english': 'I am staying for another two weeks.'},
      ],
    },
    'Tab 11_4 - vergangene Reisen': {
      'title': 'Vergangene Reisen',
      'phrases': [
        {'german': 'Warst du schon mal in Deutschland?', 'literal': 'Were you already once in Germany?', 'english': 'Have you ever been to Germany?'},
        {'german': 'Waren Sie schon mal in Deutschland?', 'literal': 'Were you already once in Germany?', 'english': 'Have you ever been to Germany?'},
        {'german': 'Nein, ich war noch nie hier.', 'literal': 'No, I was still never here.', 'english': 'No, I have never been here before.'},
        {'german': 'Ja, ich war schon mal hier.', 'literal': 'Yes, I was already once here.', 'english': 'Yes, I have been here before.'},
      ],
    },
    'Tab 11_5 - besuchte Orte': {
      'title': 'Besuchte Orte',
      'phrases': [
        {'german': 'Wo warst du?', 'literal': 'Where were you?', 'english': 'Where were you?'},
        {'german': 'Wo waren Sie?', 'literal': 'Where were you?', 'english': 'Where were you?'},
        {'german': 'Ich war schon mal in Berlin.', 'literal': 'I was already once in Berlin.', 'english': 'I have been to Berlin before.'},
        {'german': 'Ich war noch nie in München.', 'literal': 'I was still never in Munich.', 'english': 'I have never been to Munich.'},
      ],
    },
    'Tab 11_6 - Grund des Aufenthalts erfragen': {
      'title': 'Grund des Aufenthalts erfragen',
      'phrases': [
        {'german': 'Was machst du hier?', 'literal': 'What make you here?', 'english': 'What are you doing here?'},
        {'german': 'Was machen Sie hier?', 'literal': 'What make you here?', 'english': 'What are you doing here?'},
        {'german': 'Was führt dich hierher?', 'literal': 'What leads you here?', 'english': 'What brings you here?'},
        {'german': 'Was führt Sie hierher?', 'literal': 'What leads you here?', 'english': 'What brings you here?'},
      ],
    },
    'Tab 11_7 - Grund des Aufenthalts angeben': {
      'title': 'Grund des Aufenthalts angeben',
      'phrases': [
        {'german': 'Ich mache Urlaub.', 'literal': 'I make vacation.', 'english': 'I am on vacation.'},
        {'german': 'Ich arbeite hier.', 'literal': 'I work here.', 'english': 'I work here.'},
        {'german': 'Ich studiere hier.', 'literal': 'I study here.', 'english': 'I study here.'},
        {'german': 'Ich besuche Freunde.', 'literal': 'I visit friends.', 'english': 'I am visiting friends.'},
      ],
    },
    'Tab 11_8 - Grund des Aufenthalts angeben und erfragen - Alternative': {
      'title': 'Grund des Aufenthalts angeben und erfragen - Alternative',
      'phrases': [
        {'german': 'Warum bist du hier?', 'literal': 'Why are you here?', 'english': 'Why are you here?'},
        {'german': 'Warum sind Sie hier?', 'literal': 'Why are you here?', 'english': 'Why are you here?'},
        {'german': 'Weil ich hier arbeite.', 'literal': 'Because I here work.', 'english': 'Because I work here.'},
        {'german': 'Weil ich hier studiere.', 'literal': 'Because I here study.', 'english': 'Because I study here.'},
      ],
    },
    'Tab 11_9 - Grund des Aufenthalts - verkürzt': {
      'title': 'Grund des Aufenthalts - verkürzt',
      'phrases': [
        {'german': 'Weil ich hier arbeite.', 'literal': 'Because I here work.', 'english': 'Because I work here.'},
        {'german': 'Weil ich meine Familie besuche.', 'literal': 'Because I my family visit.', 'english': 'Because I am visiting my family.'},
      ],
    },
    'Tab 12_1 - Meinung zum Aufenthalt': {
      'title': 'Meinung zum Aufenthalt',
      'phrases': [
        {'german': 'Wie gefällt es euch?', 'literal': 'How appeals it you?', 'english': 'How do you like it?'},
        {'german': 'Wie gefällt es Ihnen?', 'literal': 'How appeals it you?', 'english': 'How do you like it?'},
        {'german': 'Es gefällt mir hier.', 'literal': 'It appeals me here.', 'english': 'I like it here.'},
        {'german': 'Es gefällt mir nicht.', 'literal': 'It appeals me not.', 'english': 'I don\'t like it.'},
      ],
    },
    'Tab 12_2 - Gefallen ausdrücken': {
      'title': 'Gefallen ausdrücken',
      'phrases': [
        {'german': 'Was gefällt euch?', 'literal': 'What appeals you?', 'english': 'What do you like?'},
        {'german': 'Was gefällt Ihnen?', 'literal': 'What appeals you?', 'english': 'What do you like?'},
        {'german': 'Mir gefällt das Essen.', 'literal': 'Me appeals the food.', 'english': 'I like the food.'},
        {'german': 'Mir gefallen die Leute.', 'literal': 'Me appeal the people.', 'english': 'I like the people.'},
        {'german': 'Die Leute sind nett.', 'literal': 'The people are nice.', 'english': 'The people are nice.'},
        {'german': 'Die Stadt ist schön.', 'literal': 'The city is beautiful.', 'english': 'The city is beautiful.'},
      ],
    },
    'Tab 12_3 - über das Deutschlernen sprechen': {
      'title': 'Über das Deutschlernen sprechen',
      'phrases': [
        {'german': 'Wie lange lernen Sie schon Deutsch?', 'literal': 'How long learn you already German?', 'english': 'How long have you been learning German?'},
        {'german': 'Wie lange lernst du schon Deutsch?', 'literal': 'How long learn you already German?', 'english': 'How long have you been learning German?'},
        {'german': 'Ich lerne noch nicht lange.', 'literal': 'I learn still not long.', 'english': 'I haven\'t been learning long.'},
        {'german': 'Ich lerne seit einem Jahr.', 'literal': 'I learn since one year.', 'english': 'I have been learning for a year.'},
        {'german': 'Ich bin noch Anfänger.', 'literal': 'I am still beginner.', 'english': 'I am still a beginner.'},
      ],
    },
    'Tab 12_4 - über Deutschkenntnisse sprechen': {
      'title': 'Über Deutschkenntnisse sprechen',
      'phrases': [
        {'german': 'Du sprichst schon gut Deutsch.', 'literal': 'You speak already good German.', 'english': 'You already speak good German.'},
        {'german': 'Sie sprechen schon gut Deutsch.', 'literal': 'You speak already good German.', 'english': 'You already speak good German.'},
        {'german': 'Danke, aber ich mache noch viele Fehler.', 'literal': 'Thanks, but I make still many mistakes.', 'english': 'Thanks, but I still make many mistakes.'},
        {'german': 'Ich verstehe fast alles.', 'literal': 'I understand almost everything.', 'english': 'I understand almost everything.'},
        {'german': 'Ich verstehe nicht alles.', 'literal': 'I understand not everything.', 'english': 'I don\'t understand everything.'},
        {'german': 'Die Leute sprechen zu schnell.', 'literal': 'The people speak too fast.', 'english': 'People speak too fast.'},
        {'german': 'Der Dialekt ist schwer zu verstehen.', 'literal': 'The dialect is hard to understand.', 'english': 'The dialect is hard to understand.'},
      ],
    },
    'Tab 12_5 - über besuchte Orte sprechen': {
      'title': 'Über besuchte Orte sprechen',
      'phrases': [
        {'german': 'Warst du schon mal in Deutschland?', 'literal': 'Were you already once in Germany?', 'english': 'Have you already been to Germany?'},
        {'german': 'Waren Sie schon mal in Deutschland?', 'literal': 'Were you already once in Germany?', 'english': 'Have you already been to Germany?'},
        {'german': 'Warst du schon mal in anderen Ländern?', 'literal': 'Were you already once in other countries?', 'english': 'Have you already been to other countries?'},
        {'german': 'Waren Sie schon mal in anderen Ländern?', 'literal': 'Were you already once in other countries?', 'english': 'Have you already been to other countries?'},
        {'german': 'Nein, ich war noch nie in Deutschland.', 'literal': 'No, I was still never in Germany.', 'english': 'No, I haven\'t been to Germany yet.'},
        {'german': 'Ja, ich war schon mal in Deutschland.', 'literal': 'Yes, I was already once in Germany.', 'english': 'Yes, I have already been to Germany.'},
        {'german': 'Nein, aber ich würde gerne mal nach Deutschland reisen.', 'literal': 'No, but I would gladly once to Germany travel.', 'english': 'No, but I would like to travel to Germany sometime.'},
        {'german': 'Nein, aber ich würde gerne mal nach Österreich reisen.', 'literal': 'No, but I would gladly once to Austria travel.', 'english': 'No, but I would like to travel to Austria sometime.'},
        {'german': 'Nein, aber ich würde gerne mal in die Schweiz reisen.', 'literal': 'No, but I would gladly once to the Switzerland travel.', 'english': 'No, but I would like to travel to Switzerland sometime.'},
      ],
    },
    'Tab 13_1 Hobbys nennen - Ich gehe gerne': {
      'title': 'Hobbys nennen - Ich gehe gerne',
      'phrases': [
        {'german': 'Ich gehe (nicht) gerne...', 'literal': 'I go (not) gladly...', 'english': 'I (don\'t) like to go...'},
        {'german': '... schwimmen.', 'literal': '... swim.', 'english': '... swimming.'},
        {'german': '... wandern.', 'literal': '... hike.', 'english': '... hiking.'},
        {'german': '... Fahrrad fahren.', 'literal': '... drive-wheel.', 'english': '... cycling.'},
        {'german': '... ins Kino.', 'literal': '... in(to)-the cinema.', 'english': '... to the cinema.'},
        {'german': '... in Cafés.', 'literal': '... in(to) cafés.', 'english': '... to cafés.'},
      ],
    },
    'Tab 13_2 Hobbys nennen - Ich spiele gerne': {
      'title': 'Hobbys nennen - Ich spiele gerne',
      'phrases': [
        {'german': 'Ich spiele (nicht) gerne...', 'literal': 'I play (not) gladly...', 'english': 'I (don\'t) like to play...'},
        {'german': '... Fußball.', 'literal': '... football.', 'english': '... football.'},
        {'german': '... Basketball.', 'literal': '... basketball.', 'english': '... basketball.'},
        {'german': '... Volleyball.', 'literal': '... volleyball.', 'english': '... volleyball.'},
        {'german': '... Computer spielen.', 'literal': '... computer-play.', 'english': '... computer games.'},
        {'german': '... Brettspiele spielen.', 'literal': '... board-games play.', 'english': '... board games.'},
      ],
    },
    'Tab 13_3 Hobbys nennen - Ich mache gerne': {
      'title': 'Hobbys nennen - Ich mache gerne',
      'phrases': [
        {'german': 'Ich mache (nicht) gerne...', 'literal': 'I make (not) gladly...', 'english': 'I (don\'t) enjoy...'},
        {'german': '... Sport.', 'literal': '... sport.', 'english': '... sports.'},
        {'german': '... Yoga.', 'literal': '... yoga.', 'english': '... yoga.'},
        {'german': '... Musik.', 'literal': '... music.', 'english': '... music.'},
        {'german': '... Reisen.', 'literal': '... journeys.', 'english': '... travels.'},
      ],
    },
    'Tab 13_4 Hobbys nennen - Ich verbringe gerne Zeit': {
      'title': 'Hobbys nennen - Ich verbringe gerne Zeit',
      'phrases': [
        {'german': 'Ich verbringe (nicht) gerne Zeit...', 'literal': 'I spend (not) gladly time...', 'english': 'I (don\'t) like spending time...'},
        {'german': '... mit Familie.', 'literal': '... with family.', 'english': '... with family.'},
        {'german': '... in der Natur.', 'literal': '... in the nature.', 'english': '... in nature.'},
        {'german': '... in den Bergen.', 'literal': '... in the mountains.', 'english': '... in the mountains.'},
        {'german': '... am See/am Meer.', 'literal': '... at-the lake/at-the sea.', 'english': '... at the lake/at the sea.'},
      ],
    },
    'Tab 13_5 nach Hobbys fragen': {
      'title': 'Nach Hobbys fragen',
      'phrases': [
        {'german': 'Gehst du gerne...?', 'literal': 'Go you gladly...?', 'english': 'Do you like going...?'},
        {'german': 'Gehen Sie gerne...?', 'literal': 'Go you gladly...?', 'english': 'Do you like going...?'},
        {'german': 'Spielst du gerne...?', 'literal': 'Play you gladly...?', 'english': 'Do you like playing...?'},
        {'german': 'Spielen Sie gerne...?', 'literal': 'Play you gladly...?', 'english': 'Do you like playing...?'},
        {'german': 'Machst du gerne...?', 'literal': 'Make you gladly...?', 'english': 'Do you enjoy...?'},
        {'german': 'Machen Sie gerne...?', 'literal': 'Make you gladly...?', 'english': 'Do you enjoy...?'},
        {'german': 'Verbringst du gerne...?', 'literal': 'Spend you gladly...?', 'english': 'Do you like spending...?'},
        {'german': 'Verbringen Sie gerne...?', 'literal': 'Spend you gladly...?', 'english': 'Do you like spending...?'},
      ],
    },
    'Tab 14_1 - Vorlieben ausdrücken - Filme und Serien': {
      'title': 'Vorlieben ausdrücken - Filme und Serien',
      'phrases': [
        {'german': 'Siehst du/sehr gerne Filme?', 'literal': 'See you/see gladly films?', 'english': 'Do you like watching movies?'},
        {'german': 'Magst du/mögen Sie Filme?', 'literal': 'Like you/like films?', 'english': 'Do you like movies?'},
        {'german': 'Ich sehe gerne Filme.', 'literal': 'I see gladly films.', 'english': 'I like watching movies.'},
        {'german': 'Ich mag Filme/Serien.', 'literal': 'I like films/series.', 'english': 'I like movies/series.'},
        {'german': 'Ich sehe nicht oft Filme.', 'literal': 'I see not often films.', 'english': 'I don\'t watch movies often.'},
        {'german': 'Ich sehe/mag Filme nicht so gerne.', 'literal': 'I see/like films not so gladly.', 'english': 'I don\'t really like movies.'},
      ],
    },
    'Tab 14_2 - Vorlieben ausdrücken - Essen': {
      'title': 'Vorlieben ausdrücken - Essen',
      'phrases': [
        {'german': 'Isst du/essen Sie gerne Fleisch?', 'literal': 'Eat you/eat gladly meat?', 'english': 'Do you like eating meat?'},
        {'german': 'Magst du/mögen Sie Fleisch?', 'literal': 'Like you/like meat?', 'english': 'Do you like meat?'},
        {'german': 'Ich esse gerne Fleisch/Fisch.', 'literal': 'I eat gladly meat/fish.', 'english': 'I like eating meat/fish.'},
        {'german': 'Ich mag Fleisch/Fisch.', 'literal': 'I like meat/fish.', 'english': 'I like meat/fish.'},
        {'german': 'Ich esse kein Fleisch.', 'literal': 'I eat no meat.', 'english': 'I don\'t eat meat.'},
        {'german': 'Ich esse Fleisch/Fisch nicht so gerne.', 'literal': 'I eat meat/fish not so gladly.', 'english': 'I don\'t really like meat/fish.'},
        {'german': 'Ich mag Fleisch/Fisch nicht so gerne.', 'literal': 'I like meat/fish not so gladly.', 'english': 'I don\'t really like meat/fish.'},
      ],
    },
    'Tab 14_3 - Ernährungsweise angeben': {
      'title': 'Ernährungsweise angeben',
      'phrases': [
        {'german': 'Ich bin (kein) Vegetarier.', 'literal': 'I am (no) vegetarian.', 'english': 'I am (not) a vegetarian.'},
        {'german': 'Ich bin (kein) Veganer.', 'literal': 'I am (no) vegan.', 'english': 'I am (not) a vegan.'},
      ],
    },
    'Tab 14_4 - Lieblingsdinge nennen - Bücher': {
      'title': 'Lieblingsdinge nennen - Bücher',
      'phrases': [
        {'german': 'Was ist dein/Ihr Lieblingsbuch?', 'literal': 'What is your favourite book?', 'english': 'What\'s your favorite book?'},
        {'german': 'Mein Lieblingsbuch ist...', 'literal': 'My favourite book is...', 'english': 'My favorite book is...'},
        {'german': 'Am liebsten lese ich...', 'literal': 'At-the gladly read I...', 'english': 'I especially like reading...'},
        {'german': 'Ich mag...', 'literal': 'I like...', 'english': 'I like...'},
        {'german': 'Ich liebe...', 'literal': 'I love...', 'english': 'I love...'},
      ],
    },
    'Tab 14_5 - Lieblingsdinge nennen - Essen': {
      'title': 'Lieblingsdinge nennen - Essen',
      'phrases': [
        {'german': 'Was ist dein/Ihr Lieblingsessen?', 'literal': 'What is your favourite food?', 'english': 'What\'s your favorite food?'},
        {'german': 'Mein Lieblingsessen ist...', 'literal': 'My favourite food is...', 'english': 'My favorite food is...'},
        {'german': 'Am liebsten esse ich...', 'literal': 'At-the gladly eat I...', 'english': 'I especially like eating...'},
      ],
    },
    'Tab 14_6 - Meinung ausdrücken mit gefallen': {
      'title': 'Meinung ausdrücken mit gefallen',
      'phrases': [
        {'german': 'Wie gefällt dir/Ihnen der Film?', 'literal': 'How appeals you the film?', 'english': 'How do you like the movie?'},
        {'german': 'Hat dir/Ihnen der Film gefallen?', 'literal': 'Has you the film appealed?', 'english': 'Did you like the movie?'},
        {'german': 'Der Film/das Buch gefällt mir.', 'literal': 'The film/the book appeals me.', 'english': 'I like the movie/book.'},
        {'german': 'Der Film/das Buch hat mir gefallen.', 'literal': 'The film/the book has me appealed.', 'english': 'I liked the movie/book.'},
        {'german': 'Der Film/das Buch gefällt mir nicht.', 'literal': 'The film/the book appeals me not.', 'english': 'I don\'t like the movie/book.'},
        {'german': 'Der Film/das Buch hat mir nicht gefallen.', 'literal': 'The film/the book has me not appealed.', 'english': 'I didn\'t like the movie/book.'},
      ],
    },
    'Tab 14_7 - Meinung ausdrücken mit schmecken': {
      'title': 'Meinung ausdrücken mit schmecken',
      'phrases': [
        {'german': 'Wie schmeckt dir/Ihnen das Essen?', 'literal': 'How tastes you the food?', 'english': 'How do you like the taste of the food?'},
        {'german': 'Wie schmeckt es?', 'literal': 'How tastes it?', 'english': 'How do you like the taste of it?'},
        {'german': 'Es ist/war sehr lecker.', 'literal': 'It is/was very tasty.', 'english': 'It is/was very tasty.'},
        {'german': 'Es ist/war sehr gut.', 'literal': 'It is/was very good.', 'english': 'It is/was very good.'},
        {'german': 'Das Essen schmeckt gut.', 'literal': 'The food tastes good.', 'english': 'The food tastes good.'},
        {'german': 'Das Essen schmeckt nicht gut.', 'literal': 'The food tastes not good.', 'english': 'The food doesn\'t taste good.'},
      ],
    },
    'Tab 14_8 - Gefallen ausdrücken': {
      'title': 'Gefallen ausdrücken',
      'phrases': [
        {'german': 'Der Film/das Buch gefällt mir.', 'literal': 'The film/the book appeals me.', 'english': 'The movie/the book appeals to me.'},
        {'german': 'Die Filme/die Bücher gefallen mir.', 'literal': 'The films/the books appeal me.', 'english': 'The movies/the books appeal to me.'},
      ],
    },
    'Tab 14_9 - Gefallen ausdrücken mit Adjektiven': {
      'title': 'Gefallen ausdrücken mit Adjektiven',
      'phrases': [
        {'german': 'Großartig.', 'literal': 'Great.', 'english': 'Great.'},
        {'german': 'Fantastisch.', 'literal': 'Fantastic.', 'english': 'Fantastic.'},
        {'german': 'Hervorragend.', 'literal': 'Outstanding.', 'english': 'Outstanding.'},
        {'german': 'Klasse.', 'literal': 'Class.', 'english': 'Terrific.'},
        {'german': 'Exzellent.', 'literal': 'Excellent.', 'english': 'Excellent.'},
      ],
    },
    'Tab 14_10 - Gefallen ausdrücken mit Adjektiven ugs': {
      'title': 'Gefallen ausdrücken mit Adjektiven [ugs.]',
      'phrases': [
        {'german': 'Toll.', 'literal': 'Great.', 'english': 'Great.'},
        {'german': 'Mega.', 'literal': 'Mega.', 'english': 'Mega.'},
        {'german': 'Spitze.', 'literal': 'Apex.', 'english': 'Top.'},
        {'german': 'Cool.', 'literal': 'Cool.', 'english': 'Cool.'},
        {'german': 'Nicht schlecht.', 'literal': 'Not bad.', 'english': 'Not bad.'},
      ],
    },
    'Tab 14_11 - Reaktion auf Aussagen und Vorschläge': {
      'title': 'Reaktion auf Aussagen und Vorschläge',
      'phrases': [
        {'german': 'Klingt gut.', 'literal': 'Sounds good.', 'english': 'Sounds good.'},
        {'german': 'Interessant.', 'literal': 'Interesting.', 'english': 'Interesting.'},
        {'german': 'Spannend.', 'literal': 'Exciting.', 'english': 'Exciting.'},
        {'german': 'Lustig.', 'literal': 'Funny.', 'english': 'Fun.'},
        {'german': 'Komisch.', 'literal': 'Weird.', 'english': 'Weird.'},
      ],
    },
    'Tab 14_12 - Missfallen und Unzufriedenheit ausdrücken': {
      'title': 'Missfallen und Unzufriedenheit ausdrücken',
      'phrases': [
        {'german': 'Blöd.', 'literal': 'Stupid.', 'english': 'That\'s unfortunate.'},
        {'german': 'Das ist blöd.', 'literal': 'That is stupid.', 'english': 'That\'s unfortunate.'},
        {'german': 'Mist.', 'literal': 'Manure.', 'english': 'Crap.'},
        {'german': 'So ein Mist.', 'literal': 'So a manure.', 'english': 'Such a crap.'},
      ],
    },
    'Tab 14_13 - Graduierung von Meinungen': {
      'title': 'Graduierung von Meinungen',
      'phrases': [
        {'german': 'Sehr gut/schlecht.', 'literal': 'Very good/bad.', 'english': 'Very good/bad.'},
        {'german': 'Ziemlich gut/schlecht.', 'literal': 'Quite good/bad.', 'english': 'Quite good/bad.'},
        {'german': 'Nicht so gut/schlecht.', 'literal': 'Not so good/bad.', 'english': 'Not so good/bad.'},
      ],
    },
    'Tab 15_1 - Aktionen einleiten': {
      'title': 'Aktionen einleiten',
      'phrases': [
        {'german': 'Gehen wir.', 'literal': 'Go we.', 'english': 'Let\'s go.'},
        {'german': 'Lass uns gehen.', 'literal': 'Let us go.', 'english': 'Let\'s go.'},
        {'german': 'Los geht\'s.', 'literal': '[Off] goes\'it.', 'english': 'Here we go.'},
        {'german': 'Fangen wir an.', 'literal': '[Start] we [-].', 'english': 'Let\'s get started.'},
        {'german': 'Lass uns anfangen.', 'literal': 'Let us [start].', 'english': 'Let\'s get started.'},
      ],
    },
    'Tab 15_2 - Antworten zwischen Ja und Nein': {
      'title': 'Antworten zwischen Ja und Nein',
      'phrases': [
        {'german': 'Klar.', 'literal': 'Clear.', 'english': 'Clear.'},
        {'german': 'Wahrscheinlich.', 'literal': 'Probable.', 'english': 'Probably.'},
        {'german': 'Jein.', 'literal': 'Yesno.', 'english': 'Yes and no.'},
        {'german': 'Ein bisschen.', 'literal': 'A [little bit].', 'english': 'A little bit.'},
        {'german': 'Mehr oder weniger.', 'literal': 'More or less.', 'english': 'More or less.'},
        {'german': 'Nicht unbedingt.', 'literal': 'Not unconditionally.', 'english': 'Not necessarily.'},
        {'german': 'Nicht wirklich.', 'literal': 'Not really.', 'english': 'Not really.'},
        {'german': 'Gar nicht.', 'literal': '[Not at all].', 'english': 'Not at all.'},
      ],
    },
    'Tab 15_3 - Häufigkeit und Regelmäßigkeit': {
      'title': 'Häufigkeit und Regelmäßigkeit',
      'phrases': [
        {'german': 'Immer.', 'literal': 'Always.', 'english': 'Always.'},
        {'german': 'Fast immer.', 'literal': 'Almost always.', 'english': 'Almost always.'},
        {'german': 'Oft.', 'literal': 'Often.', 'english': 'Often.'},
        {'german': 'Meistens.', 'literal': 'Mostly.', 'english': 'Most of the time.'},
        {'german': 'Manchmal.', 'literal': 'Some-time.', 'english': 'Sometimes.'},
        {'german': 'Selten.', 'literal': 'Seldom.', 'english': 'Rarely.'},
        {'german': 'Fast nie.', 'literal': 'Almost never.', 'english': 'Almost never.'},
        {'german': 'Nie.', 'literal': 'Never.', 'english': 'Never.'},
      ],
    },
    'Tab 15_4 - Gegenfragen bei Überraschung': {
      'title': 'Gegenfragen bei Überraschung',
      'phrases': [
        {'german': 'Wirklich (nicht)?', 'literal': 'Really (not)?', 'english': 'Really (not)?'},
        {'german': 'Ehrlich (nicht)?', 'literal': 'Honest (not)?', 'english': 'Honestly (not)?'},
        {'german': 'Echt (nicht)?', 'literal': 'Genuine (not)?', 'english': 'Genuinely (not)?'},
      ],
    },
    'Tab 15_5 - Sätze zur Beruhigung': {
      'title': 'Sätze zur Beruhigung',
      'phrases': [
        {'german': 'Keine Sorge.', 'literal': 'No worry.', 'english': 'No worries.'},
        {'german': 'Mach dir keine Sorge.', 'literal': 'Make yourself no worry.', 'english': 'Don\'t worry.'},
        {'german': 'Machen Sie sich keine Sorge.', 'literal': 'Make You yourself no worry.', 'english': 'Don\'t worry.'},
        {'german': 'Alles gut.', 'literal': 'All good.', 'english': 'All good.'},
        {'german': 'Nichts passiert.', 'literal': 'Nothing happened.', 'english': 'Nothing happened.'},
      ],
    },
    'Tab 15_6 - Emotionale Bewertung': {
      'title': 'Emotionale Bewertung',
      'phrases': [
        {'german': 'Zum Glück.', 'literal': 'To-the luck.', 'english': 'Luckily.'},
        {'german': 'Gott sei Dank.', 'literal': 'God [let be] thanks.', 'english': 'Thank God.'},
        {'german': 'Leider.', 'literal': 'Unfortunately.', 'english': 'Unfortunately.'},
        {'german': '(Das ist) schade.', 'literal': '(That is) [pity].', 'english': '(That\'s a) pity.'},
      ],
    },
    'Tab 15_7 - Gleichgültigkeit ausdrücken': {
      'title': 'Gleichgültigkeit ausdrücken',
      'phrases': [
        {'german': '(Es/das ist mir) egal.', 'literal': '(It/that is me) indifferent.', 'english': 'I don\'t care.'},
        {'german': '(Es/das ist mir) gleich.', 'literal': '(It/that is me) equal.', 'english': 'I don\'t care.'},
      ],
    },
    'Tab 15_8 - Gleichgültigkeit ausdrücken - Alternativen': {
      'title': 'Gleichgültigkeit ausdrücken - Alternativen',
      'phrases': [
        {'german': 'Egal.', 'literal': 'Indifferent.', 'english': 'Never mind.'},
        {'german': 'Nicht so wichtig.', 'literal': 'Not so important.', 'english': 'Never mind.'},
      ],
    },
    'Tab 15_9 - Floskeln und Redewendungen': {
      'title': 'Floskeln und Redewendungen',
      'phrases': [
        {'german': 'Früher oder später.', 'literal': 'Earlier or later.', 'english': 'Sooner or later.'},
        {'german': 'Besser spät als nie.', 'literal': 'Better late than never.', 'english': 'Better late than never.'},
        {'german': 'Langsam, aber sicher.', 'literal': 'Slow, but sure.', 'english': 'Slowly but surely.'},
        {'german': 'Schritt für Schritt.', 'literal': 'Step for step.', 'english': 'Step by step.'},
        {'german': 'Es ist, wie es ist.', 'literal': 'It is, how it is.', 'english': 'It is what it is.'},
        {'german': 'So ist das Leben.', 'literal': 'So is the life.', 'english': 'Such is life.'},
      ],
    },
    'Tab 15_10 - Aktionen einleiten und Aussagen kommentieren': {
      'title': 'Aktionen einleiten und Aussagen kommentieren',
      'phrases': [
        {'german': 'Schauen wir mal.', 'literal': 'Look we once.', 'english': 'Let\'s see.'},
        {'german': 'Mal sehen.', 'literal': 'Once see.', 'english': 'Let\'s see.'},
        {'german': 'Wir werden sehen!', 'literal': 'We will see!', 'english': 'We will see!'},
      ],
    },
    'Tab 16_1 - Aktivitäten vorschlagen - Hast du Lust': {
      'title': 'Aktivitäten vorschlagen - Hast du Lust',
      'phrases': [
        {'german': 'Hast du Lust...?', 'literal': 'Have you lust...?', 'english': 'Do you feel like...?'},
        {'german': '...einen Kaffee zu trinken?', 'literal': '...a coffee to drink?', 'english': '...having a coffee?'},
        {'german': '...etwas essen zu gehen?', 'literal': '...something eat to go?', 'english': '...going out for food?'},
        {'german': '...spazieren zu gehen?', 'literal': '...stroll to go?', 'english': '...going for a walk?'},
        {'german': '...ins Kino zu gehen?', 'literal': '...in(to)-the cinema to go?', 'english': '...going to the cinema?'},
      ],
    },
    'Tab 16_2 - Aktivitäten vorschlagen - Wollen wir': {
      'title': 'Aktivitäten vorschlagen - Wollen wir',
      'phrases': [
        {'german': 'Wollen wir...?', 'literal': 'Want we...?', 'english': 'Shall we...?'},
        {'german': '...einen Kaffee trinken?', 'literal': '...a coffee drink?', 'english': '...have a coffee?'},
        {'german': '...etwas essen gehen?', 'literal': '...something eat go?', 'english': '...go out for food?'},
        {'german': '...spazieren gehen?', 'literal': '...stroll go?', 'english': '...go for a walk?'},
        {'german': '...ins Kino gehen?', 'literal': '...in(to)-the cinema go?', 'english': '...go to the cinema?'},
      ],
    },
    'Tab 16_3 - Aktivitäten vorschlagen - Gehen wir': {
      'title': 'Aktivitäten vorschlagen - Gehen wir',
      'phrases': [
        {'german': 'Gehen wir einen Kaffee trinken?', 'literal': 'Go we a coffee drink?', 'english': 'Shall we go have a coffee?'},
        {'german': 'Gehen wir etwas essen?', 'literal': 'Go we something eat?', 'english': 'Shall we go out to eat?'},
        {'german': 'Gehen wir spazieren?', 'literal': 'Go we stroll?', 'english': 'Shall we go for a walk?'},
        {'german': 'Gehen wir ins Kino?', 'literal': 'Go we in(to)-the cinema?', 'english': 'Shall we go to the cinema?'},
      ],
    },
    'Tab 16_4 - Verfügbarkeit und Uhrzeit nennen und erfragen': {
      'title': 'Verfügbarkeit und Uhrzeit nennen und erfragen',
      'phrases': [
        {'german': 'Wann hast du Zeit?', 'literal': 'When have you time?', 'english': 'When do you have time?'},
        {'german': 'Hast du heute Zeit?', 'literal': 'Have you today time?', 'english': 'Are you free today?'},
        {'german': 'Ich habe morgen Zeit.', 'literal': 'I have tomorrow time.', 'english': 'I\'m free tomorrow.'},
        {'german': 'Am Wochenende habe ich Zeit.', 'literal': 'At-the weekend have I time.', 'english': 'I\'m free on the weekend.'},
        {'german': 'Heute geht\'s nicht.', 'literal': 'Today goes\'it not.', 'english': 'Today unfortunately doesn\'t work.'},
        {'german': 'Sonntag passt mir.', 'literal': 'Sunday suits me.', 'english': 'Sunday works for me.'},
      ],
    },
    'Tab 16_5 - Treffpunkt vorschlagen und erfragen': {
      'title': 'Treffpunkt vorschlagen und erfragen',
      'phrases': [
        {'german': 'Wo treffen wir uns?', 'literal': 'Where meet we us?', 'english': 'Where shall we meet?'},
        {'german': 'Wir können uns hier treffen.', 'literal': 'We can us here meet.', 'english': 'We can meet here.'},
        {'german': 'Wohin willst du gehen?', 'literal': 'Where-[to] want you go?', 'english': 'Where do you want to go?'},
        {'german': 'Wir können ins Café gehen.', 'literal': 'We can in(to) the café go.', 'english': 'We can go to the café.'},
        {'german': 'Wir können ins Restaurant gehen.', 'literal': 'We can in(to) the restaurant go.', 'english': 'We can go to the restaurant.'},
      ],
    },
    'Tab 16_6 - Treffen zusagen,verschieben und absagen': {
      'title': 'Treffen zusagen, verschieben und absagen',
      'phrases': [
        {'german': 'Ja, gern(e).', 'literal': 'Yes, gladly.', 'english': 'Yes, sure.'},
        {'german': 'Leider kann ich nicht.', 'literal': 'Unfortunately can I not.', 'english': 'Unfortunately I can\'t.'},
        {'german': 'Vielleicht ein anderes Mal.', 'literal': 'Maybe a other time.', 'english': 'Maybe another time.'},
        {'german': 'Können wir das Treffen verschieben?', 'literal': 'Can we the meeting postpone?', 'english': 'Can we postpone the meeting?'},
        {'german': 'Ich muss unser Treffen absagen.', 'literal': 'I must our meeting cancel.', 'english': 'I\'m afraid I have to cancel our meeting.'},
      ],
    },
    'Tab 16_7 - über das Wetter sprechen': {
      'title': 'Über das Wetter sprechen',
      'phrases': [
        {'german': 'Wie ist/wird das Wetter?', 'literal': 'How is/will the weather?', 'english': 'What is/will the weather be like?'},
        {'german': 'Es ist/wird...', 'literal': 'It is/will (be)...', 'english': 'It is/will be...'},
        {'german': '...kalt.', 'literal': '...cold.', 'english': '...cold.'},
        {'german': '...warm.', 'literal': '...warm.', 'english': '...warm.'},
        {'german': '...heiß.', 'literal': '...hot.', 'english': '...hot.'},
        {'german': '...sonnig.', 'literal': '...sunny.', 'english': '...sunny.'},
        {'german': '...regnerisch.', 'literal': '...rainy.', 'english': '...rainy.'},
      ],
    },
    'Tab 16_8 - Wetterphänomene nennen': {
      'title': 'Wetterphänomene nennen',
      'phrases': [
        {'german': 'Die Sonne scheint.', 'literal': 'The sun shines.', 'english': 'The sun is shining.'},
        {'german': 'Es regnet/wird regnen.', 'literal': 'It rains/will rain.', 'english': 'It\'s raining/will rain.'},
        {'german': 'Es schneit/wird schneien.', 'literal': 'It snows/will snow.', 'english': 'It\'s snowing/will snow.'},
      ],
    },
    'Tab 16_9 - Angaben zur Temperatur': {
      'title': 'Angaben zur Temperatur',
      'phrases': [
        {'german': 'Wie viel Grad sind es?', 'literal': 'How many degrees are it?', 'english': 'How many degrees is it?'},
        {'german': 'Es sind/werden... Grad.', 'literal': 'It are/will... degrees.', 'english': 'It is/will be... degrees.'},
      ],
    },
    'Tab 17_1 - Termine vereinbaren': {
      'title': 'Termine vereinbaren',
      'phrases': [
        {'german': 'Ich hätte gern einen Termin.', 'literal': 'I would have gladly an appointment.', 'english': 'I\'d like to make an appointment.'},
        {'german': 'Ich brauche einen Termin.', 'literal': 'I need an appointment.', 'english': 'I need an appointment.'},
        {'german': 'Wann haben Sie Zeit?', 'literal': 'When have You time?', 'english': 'When are you available?'},
        {'german': 'Wann passt es Ihnen?', 'literal': 'When suits it You?', 'english': 'When does it suit you?'},
        {'german': 'Können Sie am Montag kommen?', 'literal': 'Can You on Monday come?', 'english': 'Can you come on Monday?'},
      ],
    },
    'Tab 17_2 - Terminvorschlag zusagen und ablehnen': {
      'title': 'Terminvorschlag zusagen und ablehnen',
      'phrases': [
        {'german': 'Da habe ich leider keine Zeit.', 'literal': 'There have I unfortunately no time.', 'english': 'I (unfortunately) don\'t have time then.'},
        {'german': 'Das passt (leider) nicht.', 'literal': 'That suits (unfortunately) not.', 'english': 'That (unfortunately) doesn\'t work.'},
      ],
    },
    'Tab 17_3 - Wochenabschnitte': {
      'title': 'Wochenabschnitte',
      'phrases': [
        {'german': 'Unter der Woche arbeite ich.', 'literal': 'Under the week work I.', 'english': 'I work during the week.'},
        {'german': 'Am Wochenende habe ich frei.', 'literal': 'At-the weekend have I free.', 'english': 'I\'m free on the weekend.'},
      ],
    },
    'Tab 17_4 - Wochentage': {
      'title': 'Wochentage',
      'phrases': [
        {'german': 'Wie passt es Ihnen am Montag?', 'literal': 'How suits it You on Monday?', 'english': 'How does Monday work for you?'},
        {'german': 'Haben Sie am Dienstag Zeit?', 'literal': 'Have You on Tuesday time?', 'english': 'Are you free on Tuesday?'},
        {'german': 'Und am Mittwoch?', 'literal': 'And on Wednesday?', 'english': 'What about Wednesday?'},
        {'german': 'Was machen Sie am Donnerstag?', 'literal': 'What make You on Thursday?', 'english': 'What are you doing on Thursday?'},
        {'german': 'Können Sie am Freitag kommen?', 'literal': 'Can You on Friday come?', 'english': 'Can you come on Friday?'},
        {'german': 'Passt es Ihnen am Samstag?', 'literal': 'Suits it You on Saturday?', 'english': 'Does Saturday work for you?'},
        {'german': 'Wann passt es Ihnen?', 'literal': 'When suits it You?', 'english': 'When are you available?'},
      ],
    },
    'Tab 17_5 - Tageszeiten': {
      'title': 'Tageszeiten',
      'phrases': [
        {'german': 'Haben Sie am Morgen Zeit?', 'literal': 'Have You in the morning time?', 'english': 'Are you free in the morning?'},
        {'german': 'Passt es Ihnen am Vormittag?', 'literal': 'Suits it You in the forenoon?', 'english': 'Is morning okay for you?'},
        {'german': 'Haben Sie am Nachmittag Zeit?', 'literal': 'Have You in the afternoon time?', 'english': 'Are you free in the afternoon?'},
        {'german': 'Wie passt es Ihnen am Abend?', 'literal': 'How suits it You in the evening?', 'english': 'How about in the evening?'},
        {'german': 'Und in der Nacht?', 'literal': 'And in the night?', 'english': 'And in the night?'},
      ],
    },
    'Tab 17_6 - Tageszeiten als Adverbien': {
      'title': 'Tageszeiten als Adverbien',
      'phrases': [
        {'german': 'Ich habe morgens Zeit.', 'literal': 'I have mornings time.', 'english': 'I\'m free in the mornings.'},
        {'german': 'Vormittags arbeite ich.', 'literal': 'Fore-noons work I.', 'english': 'Morning work doesn\'t work for me.'},
        {'german': 'Ich habe mittags Zeit.', 'literal': 'I have noons time.', 'english': 'I\'m free at noon.'},
        {'german': 'Nachmittags arbeite ich.', 'literal': 'After-noons work I.', 'english': 'Afternoon work doesn\'t work for me.'},
        {'german': 'Abends passt es mir.', 'literal': 'Evenings suits it me.', 'english': 'Evening (doesn\'t) work for me.'},
        {'german': 'Nachts passt es mir nicht.', 'literal': 'Nights suits it me not.', 'english': 'Night (doesn\'t) work for me.'},
      ],
    },
    'Tab 17_7 - Wochentage als Adverbien': {
      'title': 'Wochentage als Adverbien',
      'phrases': [
        {'german': 'Montags passt es mir nicht.', 'literal': 'Mondays suits it me not.', 'english': 'Mondays (don\'t) work for me.'},
        {'german': 'Dienstags habe ich Zeit.', 'literal': 'Tuesdays have I time.', 'english': 'I\'m free on Tuesdays.'},
        {'german': 'Mittwochs arbeite ich.', 'literal': 'Wednesdays work I.', 'english': 'Wednesdays don\'t work for me.'},
        {'german': 'Donnerstags habe ich frei.', 'literal': 'Thursdays have I free.', 'english': 'I\'m off/work on Thursdays.'},
        {'german': 'Ich kann freitags kommen.', 'literal': 'I can Fridays come.', 'english': 'I can come on Fridays.'},
        {'german': 'Samstags passt es mir.', 'literal': 'Saturdays suits it me.', 'english': 'Saturdays work for me.'},
        {'german': 'Sonntags passt es mir nicht.', 'literal': 'Sundays suits it me not.', 'english': 'Sunday doesn\'t work for me.'},
      ],
    },
    'Tab 17_8 - Uhrzeit erfragen und angeben': {
      'title': 'Uhrzeit erfragen und angeben',
      'phrases': [
        {'german': 'Wie spät ist es?', 'literal': 'How late is it?', 'english': 'What time is it?'},
        {'german': 'Es ist ...', 'literal': 'It is...', 'english': 'It is ...'},
      ],
    },
    'Tab 17_9 - Uhrzeit nennen': {
      'title': 'Uhrzeit nennen',
      'phrases': [
        {'german': 'Es ist zwölf Uhr.', 'literal': 'It is twelve clock.', 'english': 'It\'s twelve o\'clock.'},
        {'german': 'Es ist ein Uhr.', 'literal': 'It is one clock.', 'english': 'It\'s one o\'clock.'},
      ],
    },
    'Tab 17_10 - Uhrzeit nennen - 24-Stunden-System': {
      'title': 'Uhrzeit nennen - 24-Stunden-System',
      'phrases': [
        {'german': 'Es ist vierzehn Uhr.', 'literal': 'It is four-ten clock.', 'english': 'It\'s two PM (14:00).'},
        {'german': 'Es ist zwei Uhr.', 'literal': 'It is two clock.', 'english': 'It\'s two o\'clock.'},
      ],
    },
    'Tab 17_11 - Uhrzeit mit Tageszeit nennen': {
      'title': 'Uhrzeit mit Tageszeit nennen',
      'phrases': [
        {'german': 'Es ist sechs Uhr morgens.', 'literal': 'It is six clock mornings.', 'english': 'It\'s six in the morning.'},
        {'german': 'Es ist sechs Uhr abends.', 'literal': 'It is six clock evenings.', 'english': 'It\'s six in the evening.'},
      ],
    },
    'Tab 17_12 - Zeitpunkt erfragen und angeben': {
      'title': 'Zeitpunkt erfragen und angeben',
      'phrases': [
        {'german': 'Um wie viel Uhr treffen wir uns?', 'literal': 'At how much clock meet we us?', 'english': 'At what time shall we meet?'},
        {'german': 'Um dreizehn Uhr.', 'literal': 'At three-ten clock.', 'english': 'At one PM (13:00).'},
        {'german': 'Um wie viel Uhr beginnt der Film?', 'literal': 'At how much clock begins the film?', 'english': 'What time does the movie start?'},
        {'german': 'Ich bin um sechs Uhr da.', 'literal': 'I am at six clock there.', 'english': 'I\'ll be there at six o\'clock.'},
      ],
    },
    'Tab 17_13 - Zeiteinheiten - Sekunde, Minute, Stunde': {
      'title': 'Zeiteinheiten - Sekunde, Minute, Stunde',
      'phrases': [
        {'german': 'Das dauert nur eine Minute.', 'literal': 'That lasts only one minute.', 'english': 'It only takes a minute.'},
        {'german': 'Das dauert nur eine Stunde.', 'literal': 'That lasts only one hour.', 'english': 'It only takes an hour.'},
        {'german': 'Das dauert nur eine Sekunde.', 'literal': 'That lasts only one second.', 'english': 'It only takes a second.'},
      ],
    },
    'Tab 18_1 - Telefonieren_Begrüßung': {
      'title': 'Telefonieren: Begrüßung',
      'phrases': [
        {'german': 'Guten Tag, Müller.', 'literal': 'Good day, Müller.', 'english': 'Hello, Mr. Müller.'},
        {'german': 'Guten Tag, Frau Weber.', 'literal': 'Good day, Mrs. Weber.', 'english': 'Hello, Mrs. Weber.'},
        {'german': 'Guten Morgen.', 'literal': 'Good morning.', 'english': 'Good morning.'},
        {'german': 'Guten Abend.', 'literal': 'Good evening.', 'english': 'Good evening.'},
      ],
    },
    'Tab 18_2 - Telefonieren_Begrüßungsformeln': {
      'title': 'Telefonieren: Begrüßungsformeln',
      'phrases': [
        {'german': 'Hier ist...', 'literal': 'Here is...', 'english': 'This is...'},
        {'german': 'Am Apparat.', 'literal': 'At the apparatus.', 'english': 'Speaking.'},
        {'german': 'Kann ich mit... sprechen?', 'literal': 'Can I with... speak?', 'english': 'Can I speak with...?'},
        {'german': 'Ist... da?', 'literal': 'Is... there?', 'english': 'Is... there?'},
      ],
    },
    'Tab 18_3 - Telefonieren_Verabschiedung': {
      'title': 'Telefonieren: Verabschiedung',
      'phrases': [
        {'german': 'Auf Wiederhören.', 'literal': 'On again-hear.', 'english': 'Goodbye.'},
        {'german': 'Einen schönen Tag noch.', 'literal': 'A beautiful day still.', 'english': 'Have a nice day.'},
        {'german': 'Bis später.', 'literal': 'Until later.', 'english': 'See you later.'},
        {'german': 'Tschüss.', 'literal': 'Bye.', 'english': 'Bye.'},
      ],
    },
    'Tab 18_4 - Telefonieren_Dank und Abschluss': {
      'title': 'Telefonieren: Dank und Abschluss',
      'phrases': [
        {'german': 'Danke für Ihr Anruf.', 'literal': 'Thanks for Your call.', 'english': 'Thank you for calling.'},
        {'german': 'Danke für die Auskunft.', 'literal': 'Thanks for the information.', 'english': 'Thank you for the information.'},
        {'german': 'Danke, das war alles.', 'literal': 'Thanks, that was everything.', 'english': 'Thank you, that was everything.'},
        {'german': 'Danke, auf Wiederhören.', 'literal': 'Thanks, on again-hear.', 'english': 'Thank you, goodbye.'},
      ],
    },
    'Tab 18_5 - Formeller Schriftverkehr - Begrüßung': {
      'title': 'Formeller Schriftverkehr: Begrüßung',
      'phrases': [
        {'german': 'Sehr geehrte Damen und Herren,', 'literal': 'Very honoured ladies and gentlemen,', 'english': 'Dear Sir or Madam,'},
        {'german': 'Sehr geehrter Herr Müller,', 'literal': 'Very honoured Mr. Müller,', 'english': 'Dear Mr. Müller,'},
        {'german': 'Sehr geehrte Frau Weber,', 'literal': 'Very honoured Mrs. Weber,', 'english': 'Dear Mrs. Weber,'},
        {'german': 'Sehr geehrte Damen,', 'literal': 'Very honoured ladies,', 'english': 'Dear Ladies,'},
      ],
    },
    'Tab 18_6 - Formeller Schriftverkehr - Verabschiedung': {
      'title': 'Formeller Schriftverkehr: Verabschiedung',
      'phrases': [
        {'german': 'Mit freundlichen Grüßen', 'literal': 'With friendly greetings', 'english': 'Kind regards'},
        {'german': 'Mit besten Grüßen', 'literal': 'With best greetings', 'english': 'Best regards'},
        {'german': 'Hochachtungsvoll', 'literal': 'High-respectfully', 'english': 'Yours faithfully'},
        {'german': 'Mit freundlicher Empfehlung', 'literal': 'With friendly recommendation', 'english': 'Yours sincerely'},
      ],
    },
    'Tab 18_7 - Informeller Schriftverkehr - Begrüßung': {
      'title': 'Informeller Schriftverkehr: Begrüßung',
      'phrases': [
        {'german': 'Hallo, Max,', 'literal': 'Hello, Max,', 'english': 'Hello, Max,'},
        {'german': 'Lieber Max,', 'literal': 'Dear Max,', 'english': 'Dear Max,'},
        {'german': 'Liebe Anna,', 'literal': 'Dear Anna,', 'english': 'Dear Anna,'},
        {'german': 'Hallo zusammen,', 'literal': 'Hello together,', 'english': 'Hello everyone,'},
      ],
    },
    'Tab 18_8 - Informeller Schriftverkehr - Verabschiedung': {
      'title': 'Informeller Schriftverkehr: Verabschiedung',
      'phrases': [
        {'german': 'Liebe Grüße', 'literal': 'Dear greetings', 'english': 'Best regards'},
        {'german': 'Beste Grüße', 'literal': 'Best greetings', 'english': 'Best regards'},
        {'german': 'Viele Grüße', 'literal': 'Many greetings', 'english': 'Many regards'},
        {'german': 'Bis bald', 'literal': 'Until soon', 'english': 'See you soon'},
        {'german': 'Tschüss', 'literal': 'Bye', 'english': 'Bye'},
      ],
    },
    'Tab 18_9 - Abkürzungen in der geschriebenen Sprache': {
      'title': 'Abkürzungen in der geschriebenen Sprache',
      'phrases': [
        {'german': 'z. B. (zum Beispiel)', 'literal': 'for example', 'english': 'e.g. (for example)'},
        {'german': 'usw. (und so weiter)', 'literal': 'and so on', 'english': 'etc. (and so on)'},
        {'german': 'etc. (et cetera)', 'literal': 'et cetera', 'english': 'etc. (et cetera)'},
        {'german': 'inkl. (inklusive)', 'literal': 'including', 'english': 'incl. (including)'},
        {'german': 'exkl. (exklusive)', 'literal': 'excluding', 'english': 'excl. (excluding)'},
        {'german': 'bzgl. (bezüglich)', 'literal': 'regarding', 'english': 're. (regarding)'},
        {'german': 'bzw. (beziehungsweise)', 'literal': 'respectively', 'english': 'resp. (respectively)'},
        {'german': 'ca. (circa)', 'literal': 'approximately', 'english': 'approx. (approximately)'},
        {'german': 'evtl. (eventuell)', 'literal': 'possibly', 'english': 'possibly'},
      ],
    },
    'Tab 19_1 - Allgemeines Befinden erfragen und ausdrücken': {
      'title': 'Allgemeines Befinden erfragen und ausdrücken',
      'phrases': [
        {'german': 'Wie fühlst du dich?', 'literal': 'How feel you yourself?', 'english': 'How do you feel?'},
        {'german': 'Wie fühlen Sie sich?', 'literal': 'How feel You yourself?', 'english': 'How do you feel?'},
        {'german': 'Ich fühle mich gut/schlecht.', 'literal': 'I feel myself good/bad.', 'english': 'I (don\'t) feel well.'},
      ],
    },
    'Tab 19_2 - Allgemeines Befinden - differenzierte Angabe': {
      'title': 'Allgemeines Befinden - differenzierte Angabe',
      'phrases': [
        {'german': '(Mir geht es) so-so.', 'literal': '(Me goes it) so-so.', 'english': 'I\'m feeling so-so.'},
        {'german': '(Mir geht es) ganz gut.', 'literal': '(Me goes it) quite good.', 'english': 'I\'m quite good.'},
      ],
    },
    'Tab 19_3 - Beschwerden erfragen': {
      'title': 'Beschwerden erfragen',
      'phrases': [
        {'german': 'Was hast du?', 'literal': 'What have you?', 'english': 'What\'s wrong with you?'},
        {'german': 'Was haben Sie?', 'literal': 'What have You?', 'english': 'What\'s wrong with you?'},
        {'german': 'Was fehlt dir?', 'literal': 'What [is missing] you?', 'english': 'What\'s the matter with you?'},
        {'german': 'Was fehlt Ihnen?', 'literal': 'What [is missing] You?', 'english': 'What\'s the matter with you?'},
      ],
    },
    'Tab 19_4 - Psychisches Befinden ausdrücken': {
      'title': 'Psychisches Befinden ausdrücken',
      'phrases': [
        {'german': 'Ich bin glücklich.', 'literal': 'I am lucky.', 'english': 'I\'m happy.'},
        {'german': 'Ich bin zufrieden.', 'literal': 'I am content.', 'english': 'I\'m content.'},
        {'german': 'Ich bin verärgert.', 'literal': 'I am upset.', 'english': 'I\'m upset.'},
        {'german': 'Ich bin traurig.', 'literal': 'I am sad.', 'english': 'I\'m sad.'},
      ],
    },
    'Tab 19_5 - Physisches Befinden ausdrücken': {
      'title': 'Physisches Befinden ausdrücken',
      'phrases': [
        {'german': 'Ich bin/fühle mich fit.', 'literal': 'I am/feel myself fit.', 'english': 'I am/feel fit.'},
        {'german': 'Ich bin/fühle mich ausgeruht.', 'literal': 'I am/feel myself rested.', 'english': 'I am/feel rested.'},
        {'german': 'Ich bin/fühle mich müde.', 'literal': 'I am/feel myself tired.', 'english': 'I am/feel tired.'},
        {'german': 'Ich bin/fühle mich gestresst.', 'literal': 'I am/feel myself stressed.', 'english': 'I am/feel stressed.'},
      ],
    },
    'Tab 19_6 - Krankheit und Beschwerden nennen': {
      'title': 'Krankheit und Beschwerden nennen',
      'phrases': [
        {'german': 'Ich bin/fühle mich krank.', 'literal': 'I am/feel myself sick.', 'english': 'I\'m sick.'},
        {'german': 'Ich habe Schmerzen.', 'literal': 'I have pain.', 'english': 'I have pain.'},
      ],
    },
    'Tab 19_7 - Beschwerden benennen - Ich habe -schmerzen': {
      'title': 'Beschwerden benennen - Ich habe -schmerzen',
      'phrases': [
        {'german': 'Ich habe Kopfschmerzen.', 'literal': 'I have head-pain.', 'english': 'I have a headache.'},
        {'german': 'Ich habe Bauchschmerzen.', 'literal': 'I have stomach-pain.', 'english': 'I have a stomachache.'},
        {'german': 'Ich habe Rückenschmerzen.', 'literal': 'I have back-pain.', 'english': 'I have back pain.'},
        {'german': 'Ich habe Zahnschmerzen.', 'literal': 'I have tooth-pain.', 'english': 'I have a toothache.'},
      ],
    },
    'Tab 19_8 - Beschwerden benennen - tut, tun weh': {
      'title': 'Beschwerden benennen - tut, tun weh',
      'phrases': [
        {'german': 'Mein Kopf tut weh.', 'literal': 'My head does pain.', 'english': 'My head hurts.'},
        {'german': 'Meine Füße tun weh.', 'literal': 'My feet do pain.', 'english': 'My feet hurt.'},
        {'german': 'Mein Rücken tut weh.', 'literal': 'My back does pain.', 'english': 'My back hurts.'},
        {'german': 'Mein Zahn tut weh.', 'literal': 'My tooth does pain.', 'english': 'My tooth hurts.'},
      ],
    },
    'Tab 19_9 - Krankheiten und Symptome benennen': {
      'title': 'Krankheiten und Symptome benennen',
      'phrases': [
        {'german': 'Ich habe eine Erkältung.', 'literal': 'I have a cold.', 'english': 'I have a cold.'},
        {'german': 'Ich habe eine Grippe.', 'literal': 'I have a flu.', 'english': 'I have the flu.'},
        {'german': 'Ich habe Fieber.', 'literal': 'I have fever.', 'english': 'I have a fever.'},
        {'german': 'Ich habe Husten.', 'literal': 'I have cough.', 'english': 'I have a cough.'},
        {'german': 'Ich habe Schnupfen.', 'literal': 'I have [runny nose].', 'english': 'I have a runny nose.'},
      ],
    },
    'Tab 19_10 - Genesungswünsche': {
      'title': 'Genesungswünsche',
      'phrases': [
        {'german': 'Gute Besserung!', 'literal': 'Good betterment!', 'english': 'Get well soon!'},
        {'german': 'Ich hoffe, es geht dir/Ihnen bald besser.', 'literal': 'I hope, it goes you soon better.', 'english': 'I hope you feel better soon.'},
        {'german': 'Ruh dich aus!', 'literal': 'Rest yourself!', 'english': 'Get rest and relax!'},
        {'german': 'Ruhen Sie sich aus!', 'literal': 'Rest You yourself!', 'english': 'Get rest and relax!'},
      ],
    },
    'Tab 20_1 - Wohnsituation beschreiben': {
      'title': 'Wohnsituation beschreiben',
      'phrases': [
        {'german': 'Ich wohne in einer Wohnung.', 'literal': 'I reside in a flat.', 'english': 'I live in a flat/apartment.'},
        {'german': 'Die Wohnung ist groß/klein.', 'literal': 'The flat is big/small.', 'english': 'The flat/house is big/small.'},
        {'german': 'Ich wohne allein/mit Familie.', 'literal': 'I reside alone/with family.', 'english': 'I live alone/with family.'},
        {'german': 'Ich habe ein kleines Zimmer.', 'literal': 'I have a small room.', 'english': 'I have a small room.'},
        {'german': 'Ich habe eine Küche.', 'literal': 'I have a kitchen.', 'english': 'I have a kitchen.'},
      ],
    },
    'Tab 20_2 - vorübergehende Wohnsituation beschreiben': {
      'title': 'Vorübergehende Wohnsituation beschreiben',
      'phrases': [
        {'german': 'Ich wohne...', 'literal': 'I reside...', 'english': 'I live ...'},
        {'german': '... in einem Hotel.', 'literal': '... in a hotel.', 'english': '... in a hotel.'},
        {'german': '... in einem Hostel.', 'literal': '... in a hostel.', 'english': '... in a hostel.'},
        {'german': '... in einer Ferienwohnung.', 'literal': '... in a holiday flat.', 'english': '... in a holiday apartment.'},
        {'german': '... bei Freunden/Familie.', 'literal': '... by friends/family.', 'english': '... with friends/family.'},
      ],
    },
    'Tab 20_3 - Wohnsituation beschreiben_Wir-Form': {
      'title': 'Wohnsituation beschreiben - Wir-Form',
      'phrases': [
        {'german': 'Wir wohnen in einem Haus.', 'literal': 'We reside in a house.', 'english': 'We live in a house.'},
        {'german': 'Wir haben drei Zimmer.', 'literal': 'We have three rooms.', 'english': 'We have three rooms.'},
        {'german': 'Wir haben ein großes Wohnzimmer.', 'literal': 'We have a big living room.', 'english': 'We have a big living room.'},
      ],
    },
    'Tab 20_4 - Details zur Wohnsituation angeben': {
      'title': 'Details zur Wohnsituation angeben',
      'phrases': [
        {'german': 'Ich wohne im zweiten Stock.', 'literal': 'I reside in-the second floor.', 'english': 'I live on the second floor.'},
        {'german': 'Die Wohnung ist im Zentrum.', 'literal': 'The flat is in the centre.', 'english': 'The flat is in the centre.'},
        {'german': 'Es gibt fünf Stockwerke.', 'literal': 'It gives five floors.', 'english': 'There are five floors.'},
        {'german': 'Es gibt einen Aufzug.', 'literal': 'It gives an elevator.', 'english': 'There is an elevator.'},
        {'german': 'Es gibt einen Parkplatz.', 'literal': 'It gives a parking space.', 'english': 'There is a parking space.'},
        {'german': 'Es gibt einen Garten.', 'literal': 'It gives a garden.', 'english': 'There is a garden.'},
        {'german': 'Ich habe ein kleines Bad.', 'literal': 'I have a small bathroom.', 'english': 'I have a small bathroom.'},
        {'german': 'Ich habe einen Balkon.', 'literal': 'I have a balcony.', 'english': 'I have a balcony.'},
      ],
    },
    'Tab 20_5 - Hausarbeiten nennen': {
      'title': 'Hausarbeiten nennen',
      'phrases': [
        {'german': 'Ich mache heute die Wäsche.', 'literal': 'I make today the laundry.', 'english': 'I\'m doing the laundry today.'},
        {'german': 'Ich muss (noch) putzen.', 'literal': 'I must (still) clean.', 'english': 'I (still) have to clean.'},
        {'german': 'Ich muss (noch) aufräumen.', 'literal': 'I must (still) tidy up.', 'english': 'I (still) have to tidy up.'},
        {'german': 'Ich muss (noch) einkaufen.', 'literal': 'I must (still) shop.', 'english': 'I (still) have to shop.'},
        {'german': 'Ich koche jeden Tag.', 'literal': 'I cook every day.', 'english': 'I cook every day.'},
      ],
    },
    'Tab 20_6 - Probleme im Haushalt melden': {
      'title': 'Probleme im Haushalt melden',
      'phrases': [
        {'german': 'Die Heizung funktioniert nicht.', 'literal': 'The heating works not.', 'english': 'The heating doesn\'t work.'},
        {'german': 'Das Licht geht nicht an.', 'literal': 'The light goes not on.', 'english': 'The light doesn\'t work.'},
        {'german': 'Der Kühlschrank ist kaputt.', 'literal': 'The cool-cupboard is broken.', 'english': 'The fridge is broken.'},
        {'german': 'Ich habe kein warmes Wasser.', 'literal': 'I have no warm water.', 'english': 'I have no hot water.'},
        {'german': 'Es gibt ein Problem mit der Dusche.', 'literal': 'It gives a problem with the shower.', 'english': 'There\'s a problem with the shower.'},
      ],
    },
    'Tab 20_7 - Besuch empfangen': {
      'title': 'Besuch empfangen',
      'phrases': [
        {'german': 'Komm rein!', 'literal': 'Come [here] in!', 'english': 'Come in!'},
        {'german': 'Kommen Sie rein!', 'literal': 'Come You [here] in!', 'english': 'Come in!'},
        {'german': 'Fühl dich wie zu Hause.', 'literal': 'Feel yourself like at home.', 'english': 'Make yourself at home.'},
        {'german': 'Fühlen Sie sich wie zu Hause.', 'literal': 'Feel You yourself like at home.', 'english': 'Make yourself at home.'},
      ],
    },
    'Tab 20_8 - Besuch bewirten': {
      'title': 'Besuch bewirten',
      'phrases': [
        {'german': 'Willst du etwas trinken?', 'literal': 'Want you something drink?', 'english': 'Do you want something to drink?'},
        {'german': 'Wollen Sie etwas trinken?', 'literal': 'Want You something drink?', 'english': 'Do you want something to drink?'},
        {'german': 'Hast du Hunger?', 'literal': 'Have you hunger?', 'english': 'Are you hungry?'},
        {'german': 'Haben Sie Hunger?', 'literal': 'Have You hunger?', 'english': 'Are you hungry?'},
        {'german': 'Möchtest du etwas essen?', 'literal': 'Would like you something eat?', 'english': 'Would you like something to eat?'},
      ],
    },
    'Tab 20_9 - Wohnungsführung': {
      'title': 'Wohnungsführung',
      'phrases': [
        {'german': 'Hier ist das Esszimmer.', 'literal': 'Here is the dining room.', 'english': 'Here is the dining room.'},
        {'german': 'Die Toilette ist im Bad.', 'literal': 'The toilet is in the bathroom.', 'english': 'The toilet is in the bathroom.'},
        {'german': 'Das ist das Schlafzimmer.', 'literal': 'That is the bedroom.', 'english': 'This is the bedroom.'},
        {'german': 'Hier ist die Küche.', 'literal': 'Here is the kitchen.', 'english': 'Here is the kitchen.'},
        {'german': 'Das ist das Wohnzimmer.', 'literal': 'That is the living room.', 'english': 'This is the living room.'},
      ],
    },
    'Ref_1 - Alphabet und Buchstabiertafel': {
      'title': 'Alphabet und Buchstabiertafel',
      'phrases': [
        {'german': 'a, A - Anton, Apfel', 'literal': 'a, A - Anton, Apple', 'english': 'a, A - Anton, Apple'},
        {'german': 'b, B - Berta, Banane', 'literal': 'b, B - Berta, Banana', 'english': 'b, B - Berta, Banana'},
        {'german': 'c, C - Cäsar, Computer', 'literal': 'c, C - Caesar, Computer', 'english': 'c, C - Caesar, Computer'},
        {'german': 'd, D - Dora, Dose', 'literal': 'd, D - Dora, Can', 'english': 'd, D - Dora, Can'},
        {'german': 'e, E - Emil, Essen', 'literal': 'e, E - Emil, Food', 'english': 'e, E - Emil, Food'},
        {'german': 'f, F - Friedrich, Falle', 'literal': 'f, F - Friedrich, Trap', 'english': 'f, F - Friedrich, Trap'},
        {'german': 'g, G - Gustav, Garten', 'literal': 'g, G - Gustav, Garden', 'english': 'g, G - Gustav, Garden'},
        {'german': 'h, H - Heinrich, Haus', 'literal': 'h, H - Heinrich, House', 'english': 'h, H - Heinrich, House'},
        {'german': 'i, I - Ida, Insel', 'literal': 'i, I - Ida, Island', 'english': 'i, I - Ida, Island'},
        {'german': 'j, J - Julius, Jacke', 'literal': 'j, J - Julius, Jacket', 'english': 'j, J - Julius, Jacket'},
        {'german': 'k, K - Kaufmann, Kurt', 'literal': 'k, K - Merchant, Kurt', 'english': 'k, K - Merchant, Kurt'},
        {'german': 'l, L - Ludwig, Lampe', 'literal': 'l, L - Ludwig, Lamp', 'english': 'l, L - Ludwig, Lamp'},
        {'german': 'm, M - Martha, Maus', 'literal': 'm, M - Martha, Mouse', 'english': 'm, M - Martha, Mouse'},
        {'german': 'n, N - Nordpol, Nase', 'literal': 'n, N - North Pole, Nose', 'english': 'n, N - North Pole, Nose'},
        {'german': 'o, O - Otto, Oma', 'literal': 'o, O - Otto, Grandma', 'english': 'o, O - Otto, Grandma'},
        {'german': 'p, P - Paula, Pizza', 'literal': 'p, P - Paula, Pizza', 'english': 'p, P - Paula, Pizza'},
        {'german': 'q, Q - Quelle, Quiz', 'literal': 'q, Q - Source, Quiz', 'english': 'q, Q - Source, Quiz'},
        {'german': 'r, R - Richard, Rock', 'literal': 'r, R - Richard, Rock', 'english': 'r, R - Richard, Rock'},
        {'german': 's, S - Samuel, Sonne', 'literal': 's, S - Samuel, Sun', 'english': 's, S - Samuel, Sun'},
        {'german': 't, T - Theodor, Tanz', 'literal': 't, T - Theodor, Dance', 'english': 't, T - Theodor, Dance'},
        {'german': 'u, U - Ulrich, Uhr', 'literal': 'u, U - Ulrich, Clock', 'english': 'u, U - Ulrich, Clock'},
        {'german': 'v, V - Viktor, Vogel', 'literal': 'v, V - Viktor, Bird', 'english': 'v, V - Viktor, Bird'},
        {'german': 'w, W - Wilhelm, Wasser', 'literal': 'w, W - Wilhelm, Water', 'english': 'w, W - Wilhelm, Water'},
        {'german': 'x, X - Xanthippe, Xylophon', 'literal': 'x, X - Xanthippe, Xylophone', 'english': 'x, X - Xanthippe, Xylophone'},
        {'german': 'y, Y - Ypsilon, Yoga', 'literal': 'y, Y - Ypsilon, Yoga', 'english': 'y, Y - Ypsilon, Yoga'},
        {'german': 'z, Z - Zacharias, Zug', 'literal': 'z, Z - Zacharias, Train', 'english': 'z, Z - Zacharias, Train'},
        {'german': 'ä, Ä - Ärger, Apfel', 'literal': 'ä, Ä - Anger, Apple', 'english': 'ä, Ä - Anger, Apple'},
        {'german': 'ö, Ö - Ökonom, Öl', 'literal': 'ö, Ö - Economist, Oil', 'english': 'ö, Ö - Economist, Oil'},
        {'german': 'ü, Ü - Übermut, Über', 'literal': 'ü, Ü - High spirits, Over', 'english': 'ü, Ü - High spirits, Over'},
        {'german': 'ß, SS - Essen, Straße', 'literal': 'ß, SS - Eat, Street', 'english': 'ß, SS - Eat, Street'},
      ],
    },
    'Ref_2 - Ländernamen': {
      'title': 'Ländernamen',
      'phrases': [
        {'german': 'Deutschland - Deutsch - Ich komme aus Deutschland.', 'literal': 'Germany - German - I come from Germany.', 'english': 'Germany - German - I come from Germany.'},
        {'german': 'Österreich - Österreicher/in - Ich komme aus Österreich.', 'literal': 'Austria - Austrian - I come from Austria.', 'english': 'Austria - Austrian - I come from Austria.'},
        {'german': 'die Schweiz - Schweizer/in - Ich komme aus der Schweiz.', 'literal': 'Switzerland - Swiss - I come from Switzerland.', 'english': 'Switzerland - Swiss - I come from Switzerland.'},
        {'german': 'England/vom Vereinigten Königreich - Engländer/in - Ich komme aus England/vom Vereinigten Königreich.', 'literal': 'England/United Kingdom - English - I come from England/United Kingdom.', 'english': 'England/United Kingdom - English - I come from England/United Kingdom.'},
        {'german': 'Frankreich - Franzose/Französin - Ich komme aus Frankreich.', 'literal': 'France - French - I come from France.', 'english': 'France - French - I come from France.'},
        {'german': 'Italien - Italiener/in - Ich komme aus Italien.', 'literal': 'Italy - Italian - I come from Italy.', 'english': 'Italy - Italian - I come from Italy.'},
        {'german': 'Spanien - Spanier/in - Ich komme aus Spanien.', 'literal': 'Spain - Spanish - I come from Spain.', 'english': 'Spain - Spanish - I come from Spain.'},
        {'german': 'die Ukraine - Ukrainer/in - Ich komme aus der Ukraine.', 'literal': 'Ukraine - Ukrainian - I come from Ukraine.', 'english': 'Ukraine - Ukrainian - I come from Ukraine.'},
        {'german': 'Russland - Russe/Russin - Ich komme aus Russland.', 'literal': 'Russia - Russian - I come from Russia.', 'english': 'Russia - Russian - I come from Russia.'},
        {'german': 'Polen - Pole/Polin - Ich komme aus Polen.', 'literal': 'Poland - Polish - I come from Poland.', 'english': 'Poland - Polish - I come from Poland.'},
        {'german': 'Rumänien - Rumäne/Rumänin - Ich komme aus Rumänien.', 'literal': 'Romania - Romanian - I come from Romania.', 'english': 'Romania - Romanian - I come from Romania.'},
        {'german': 'die Türkei - Türke/Türkin - Ich komme aus der Türkei.', 'literal': 'Turkey - Turkish - I come from Turkey.', 'english': 'Turkey - Turkish - I come from Turkey.'},
        {'german': 'Griechenland - Grieche/Griechin - Ich komme aus Griechenland.', 'literal': 'Greece - Greek - I come from Greece.', 'english': 'Greece - Greek - I come from Greece.'},
        {'german': 'die Niederlande - Niederländer/in - Ich komme aus den Niederlanden.', 'literal': 'Netherlands - Dutch - I come from Netherlands.', 'english': 'Netherlands - Dutch - I come from Netherlands.'},
        {'german': 'China - Chinese/Chinesin - Ich komme aus China.', 'literal': 'China - Chinese - I come from China.', 'english': 'China - Chinese - I come from China.'},
        {'german': 'Japan - Japaner/in - Ich komme aus Japan.', 'literal': 'Japan - Japanese - I come from Japan.', 'english': 'Japan - Japanese - I come from Japan.'},
        {'german': 'Südkorea - Koreaner/in - Ich komme aus Südkorea.', 'literal': 'South Korea - Korean - I come from South Korea.', 'english': 'South Korea - Korean - I come from South Korea.'},
        {'german': 'Indonesien - Indonesier/in - Ich komme aus Indonesien.', 'literal': 'Indonesia - Indonesian - I come from Indonesia.', 'english': 'Indonesia - Indonesian - I come from Indonesia.'},
      ],
    },
    'Ref_3 - Städtenamen': {
      'title': 'Städtenamen',
      'phrases': [
        {'german': 'Berlin - Berliner/in - Ich wohne in Berlin.', 'literal': 'Berlin - Berliner - I live in Berlin.', 'english': 'Berlin - Berliner - I live in Berlin.'},
        {'german': 'München - Münchner/in - Ich wohne in München.', 'literal': 'Munich - Munich resident - I live in Munich.', 'english': 'Munich - Munich resident - I live in Munich.'},
        {'german': 'Hamburg - Hamburger/in - Ich wohne in Hamburg.', 'literal': 'Hamburg - Hamburger - I live in Hamburg.', 'english': 'Hamburg - Hamburger - I live in Hamburg.'},
        {'german': 'Köln - Kölner/in - Ich wohne in Köln.', 'literal': 'Cologne - Cologne resident - I live in Cologne.', 'english': 'Cologne - Cologne resident - I live in Cologne.'},
        {'german': 'Wien - Wiener/in - Ich wohne in Wien.', 'literal': 'Vienna - Viennese - I live in Vienna.', 'english': 'Vienna - Viennese - I live in Vienna.'},
        {'german': 'Salzburg - Salzburger/in - Ich wohne in Salzburg.', 'literal': 'Salzburg - Salzburg resident - I live in Salzburg.', 'english': 'Salzburg - Salzburg resident - I live in Salzburg.'},
        {'german': 'Zürich - Zürcher/in - Ich wohne in Zürich.', 'literal': 'Zurich - Zurich resident - I live in Zurich.', 'english': 'Zurich - Zurich resident - I live in Zurich.'},
        {'german': 'Bern - Berner/in - Ich wohne in Bern.', 'literal': 'Bern - Bern resident - I live in Bern.', 'english': 'Bern - Bern resident - I live in Bern.'},
        {'german': 'Basel - Basler/in - Ich wohne in Basel.', 'literal': 'Basel - Basel resident - I live in Basel.', 'english': 'Basel - Basel resident - I live in Basel.'},
        {'german': 'Genf - Genfer/in - Ich wohne in Genf.', 'literal': 'Geneva - Geneva resident - I live in Geneva.', 'english': 'Geneva - Geneva resident - I live in Geneva.'},
      ],
    },
    'Ref_4 - Berufsbezeichnungen': {
      'title': 'Berufsbezeichnungen',
      'phrases': [
        {'german': 'Lehrer/Lehrerin - teacher - Ich bin Lehrer/in.', 'literal': 'Teacher - teacher - I am teacher.', 'english': 'Teacher - teacher - I am a teacher.'},
        {'german': 'Arzt/Ärztin - doctor - Ich bin Arzt/Ärztin.', 'literal': 'Doctor - doctor - I am doctor.', 'english': 'Doctor - doctor - I am a doctor.'},
        {'german': 'Verkäufer/Verkäuferin - salesperson - Ich bin Verkäufer/in.', 'literal': 'Salesperson - salesperson - I am salesperson.', 'english': 'Salesperson - salesperson - I am a salesperson.'},
        {'german': 'Ingenieur/Ingenieurin - engineer - Ich bin Ingenieur/in.', 'literal': 'Engineer - engineer - I am engineer.', 'english': 'Engineer - engineer - I am an engineer.'},
        {'german': 'Manager/Managerin - manager - Ich bin Manager/in.', 'literal': 'Manager - manager - I am manager.', 'english': 'Manager - manager - I am a manager.'},
        {'german': 'Student/Studentin - student - Ich bin Student/in.', 'literal': 'Student - student - I am student.', 'english': 'Student - student - I am a student.'},
        {'german': 'Koch/Köchin - cook - Ich bin Koch/Köchin.', 'literal': 'Cook - cook - I am cook.', 'english': 'Cook - cook - I am a cook.'},
        {'german': 'Mechaniker/Mechanikerin - mechanic - Ich bin Mechaniker/in.', 'literal': 'Mechanic - mechanic - I am mechanic.', 'english': 'Mechanic - mechanic - I am a mechanic.'},
        {'german': 'Forscher/Forscherin - researcher - Ich bin Forscher/in.', 'literal': 'Researcher - researcher - I am researcher.', 'english': 'Researcher - researcher - I am a researcher.'},
        {'german': 'Professor/Professorin - professor - Ich bin Professor/in.', 'literal': 'Professor - professor - I am professor.', 'english': 'Professor - professor - I am a professor.'},
      ],
    },
    'Ref_5 - Kardinalzahlen': {
      'title': 'Kardinalzahlen',
      'phrases': [
        {'german': 'eins - 1', 'literal': 'one - 1', 'english': 'one - 1'},
        {'german': 'zwei - 2', 'literal': 'two - 2', 'english': 'two - 2'},
        {'german': 'drei - 3', 'literal': 'three - 3', 'english': 'three - 3'},
        {'german': 'vier - 4', 'literal': 'four - 4', 'english': 'four - 4'},
        {'german': 'fünf - 5', 'literal': 'five - 5', 'english': 'five - 5'},
        {'german': 'sechs - 6', 'literal': 'six - 6', 'english': 'six - 6'},
        {'german': 'sieben - 7', 'literal': 'seven - 7', 'english': 'seven - 7'},
        {'german': 'acht - 8', 'literal': 'eight - 8', 'english': 'eight - 8'},
        {'german': 'neun - 9', 'literal': 'nine - 9', 'english': 'nine - 9'},
        {'german': 'zehn - 10', 'literal': 'ten - 10', 'english': 'ten - 10'},
        {'german': 'elf - 11', 'literal': 'eleven - 11', 'english': 'eleven - 11'},
        {'german': 'zwölf - 12', 'literal': 'twelve - 12', 'english': 'twelve - 12'},
        {'german': 'dreizehn - 13', 'literal': 'thirteen - 13', 'english': 'thirteen - 13'},
        {'german': 'vierzehn - 14', 'literal': 'fourteen - 14', 'english': 'fourteen - 14'},
        {'german': 'fünfzehn - 15', 'literal': 'fifteen - 15', 'english': 'fifteen - 15'},
        {'german': 'sechzehn - 16', 'literal': 'sixteen - 16', 'english': 'sixteen - 16'},
        {'german': 'siebzehn - 17', 'literal': 'seventeen - 17', 'english': 'seventeen - 17'},
        {'german': 'achtzehn - 18', 'literal': 'eighteen - 18', 'english': 'eighteen - 18'},
        {'german': 'neunzehn - 19', 'literal': 'nineteen - 19', 'english': 'nineteen - 19'},
        {'german': 'zwanzig - 20', 'literal': 'twenty - 20', 'english': 'twenty - 20'},
        {'german': 'einundzwanzig - 21', 'literal': 'twenty-one - 21', 'english': 'twenty-one - 21'},
        {'german': 'dreißig - 30', 'literal': 'thirty - 30', 'english': 'thirty - 30'},
        {'german': 'vierzig - 40', 'literal': 'forty - 40', 'english': 'forty - 40'},
        {'german': 'fünfzig - 50', 'literal': 'fifty - 50', 'english': 'fifty - 50'},
        {'german': 'sechzig - 60', 'literal': 'sixty - 60', 'english': 'sixty - 60'},
        {'german': 'siebzig - 70', 'literal': 'seventy - 70', 'english': 'seventy - 70'},
        {'german': 'achtzig - 80', 'literal': 'eighty - 80', 'english': 'eighty - 80'},
        {'german': 'neunzig - 90', 'literal': 'ninety - 90', 'english': 'ninety - 90'},
        {'german': 'einhundert - 100', 'literal': 'one hundred - 100', 'english': 'one hundred - 100'},
        {'german': 'einhunderteins - 101', 'literal': 'one hundred one - 101', 'english': 'one hundred one - 101'},
        {'german': 'eintausend - 1,000', 'literal': 'one thousand - 1,000', 'english': 'one thousand - 1,000'},
        {'german': 'eine Million - 1,000,000', 'literal': 'one million - 1,000,000', 'english': 'one million - 1,000,000'},
        {'german': 'zwei Millionen - 2,000,000', 'literal': 'two millions - 2,000,000', 'english': 'two million - 2,000,000'},
        {'german': 'eine Milliarde - 1,000,000,000', 'literal': 'one billion - 1,000,000,000', 'english': 'one billion - 1,000,000,000'},
        {'german': 'zwei Milliarden - 2,000,000,000', 'literal': 'two billions - 2,000,000,000', 'english': 'two billion - 2,000,000,000'},
      ],
    },
    'Ref_6 - Ordinalzahlen': {
      'title': 'Ordinalzahlen',
      'phrases': [
        {'german': 'erster - first - Ich habe am ersten Geburtstag.', 'literal': 'first - first - I have on the first birthday.', 'english': 'first - first - My birthday is on the first.'},
        {'german': 'zweiter - second - Ich habe am zweiten Geburtstag.', 'literal': 'second - second - I have on the second birthday.', 'english': 'second - second - My birthday is on the second.'},
        {'german': 'dritter - third - Ich habe am dritten Geburtstag.', 'literal': 'third - third - I have on the third birthday.', 'english': 'third - third - My birthday is on the third.'},
        {'german': 'vierter - fourth - Ich habe am vierten Geburtstag.', 'literal': 'fourth - fourth - I have on the fourth birthday.', 'english': 'fourth - fourth - My birthday is on the fourth.'},
        {'german': 'fünfter - fifth - Ich habe am fünften Geburtstag.', 'literal': 'fifth - fifth - I have on the fifth birthday.', 'english': 'fifth - fifth - My birthday is on the fifth.'},
        {'german': 'sechster - sixth - Ich habe am sechsten Geburtstag.', 'literal': 'sixth - sixth - I have on the sixth birthday.', 'english': 'sixth - sixth - My birthday is on the sixth.'},
        {'german': 'siebter - seventh - Ich habe am siebten Geburtstag.', 'literal': 'seventh - seventh - I have on the seventh birthday.', 'english': 'seventh - seventh - My birthday is on the seventh.'},
        {'german': 'achter - eighth - Ich habe am achten Geburtstag.', 'literal': 'eighth - eighth - I have on the eighth birthday.', 'english': 'eighth - eighth - My birthday is on the eighth.'},
        {'german': 'neunter - ninth - Ich habe am neunten Geburtstag.', 'literal': 'ninth - ninth - I have on the ninth birthday.', 'english': 'ninth - ninth - My birthday is on the ninth.'},
        {'german': 'zehnter - tenth - Ich habe am zehnten Geburtstag.', 'literal': 'tenth - tenth - I have on the tenth birthday.', 'english': 'tenth - tenth - My birthday is on the tenth.'},
        {'german': 'elfter - eleventh - Ich habe am elften Geburtstag.', 'literal': 'eleventh - eleventh - I have on the eleventh birthday.', 'english': 'eleventh - eleventh - My birthday is on the eleventh.'},
        {'german': 'zwölfter - twelfth - Ich habe am zwölften Geburtstag.', 'literal': 'twelfth - twelfth - I have on the twelfth birthday.', 'english': 'twelfth - twelfth - My birthday is on the twelfth.'},
        {'german': 'dreizehnter - thirteenth - Ich habe am dreizehnten Geburtstag.', 'literal': 'thirteenth - thirteenth - I have on the thirteenth birthday.', 'english': 'thirteenth - thirteenth - My birthday is on the thirteenth.'},
        {'german': 'vierzehnter - fourteenth - Ich habe am vierzehnten Geburtstag.', 'literal': 'fourteenth - fourteenth - I have on the fourteenth birthday.', 'english': 'fourteenth - fourteenth - My birthday is on the fourteenth.'},
        {'german': 'zwanzigster - twentieth - Ich habe am zwanzigsten Geburtstag.', 'literal': 'twentieth - twentieth - I have on the twentieth birthday.', 'english': 'twentieth - twentieth - My birthday is on the twentieth.'},
        {'german': 'dreißigster - thirtieth - Ich habe am dreißigsten Geburtstag.', 'literal': 'thirtieth - thirtieth - I have on the thirtieth birthday.', 'english': 'thirtieth - thirtieth - My birthday is on the thirtieth.'},
        {'german': 'einunddreißigster - thirty-first - Ich habe am einunddreißigsten Geburtstag.', 'literal': 'thirty-first - thirty-first - I have on the thirty-first birthday.', 'english': 'thirty-first - thirty-first - My birthday is on the thirty-first.'},
        {'german': 'hundertster - hundredth - Das ist der hundertste.', 'literal': 'hundredth - hundredth - That is the hundredth.', 'english': 'hundredth - hundredth - That is the hundredth.'},
        {'german': 'tausendster - thousandth - Das ist der tausendste.', 'literal': 'thousandth - thousandth - That is the thousandth.', 'english': 'thousandth - thousandth - That is the thousandth.'},
        {'german': 'millionster - millionth - Das ist der millionste.', 'literal': 'millionth - millionth - That is the millionth.', 'english': 'millionth - millionth - That is the millionth.'},
        {'german': 'milliardster - milliardth - Das ist der milliardste.', 'literal': 'milliardth - milliardth - That is the milliardth.', 'english': 'billionth - billionth - That is the billionth.'},
      ],
    },
    'Ref_7 - Monatsnamen': {
      'title': 'Monatsnamen',
      'phrases': [
        {'german': 'der Januar - January - Heute ist der erste Januar.', 'literal': 'the January - January - Today is the first January.', 'english': 'January - January - Today is the first of January.'},
        {'german': 'der Februar - February - Ich bin im Februar geboren.', 'literal': 'the February - February - I am in February born.', 'english': 'February - February - I was born in February.'},
        {'german': 'der März - March - Wann ist dein Geburtstag? Im März.', 'literal': 'the March - March - When is your birthday? In March.', 'english': 'March - March - When is your birthday? In March.'},
        {'german': 'der April - April - Ich komme im April.', 'literal': 'the April - April - I come in April.', 'english': 'April - April - I am coming in April.'},
        {'german': 'der Mai - May - Im Mai habe ich Ferien.', 'literal': 'the May - May - In May have I holidays.', 'english': 'May - May - I have holidays in May.'},
        {'german': 'der Juni - June - Im Juni ist es warm.', 'literal': 'the June - June - In June is it warm.', 'english': 'June - June - It is warm in June.'},
        {'german': 'der Juli - July - Im Juli ist es heiß.', 'literal': 'the July - July - In July is it hot.', 'english': 'July - July - It is hot in July.'},
        {'german': 'der August - August - Im August ist es sehr heiß.', 'literal': 'the August - August - In August is it very hot.', 'english': 'August - August - It is very hot in August.'},
        {'german': 'der September - September - Im September ist es kühl.', 'literal': 'the September - September - In September is it cool.', 'english': 'September - September - It is cool in September.'},
        {'german': 'der Oktober - October - Im Oktober ist es kalt.', 'literal': 'the October - October - In October is it cold.', 'english': 'October - October - It is cold in October.'},
        {'german': 'der November - November - Im November ist es sehr kalt.', 'literal': 'the November - November - In November is it very cold.', 'english': 'November - November - It is very cold in November.'},
        {'german': 'der Dezember - December - Im Dezember ist es sehr kalt.', 'literal': 'the December - December - In December is it very cold.', 'english': 'December - December - It is very cold in December.'},
      ],
    },
    'Ref_8 - Farben': {
      'title': 'Farben',
      'phrases': [
        {'german': 'das Schwarz/schwarz - black - Die Katze ist schwarz.', 'literal': 'the black/black - black - The cat is black.', 'english': 'black - black - The cat is black.'},
        {'german': 'das Weiß/weiß - white - Das Hemd ist weiß.', 'literal': 'the white/white - white - The shirt is white.', 'english': 'white - white - The shirt is white.'},
        {'german': 'das Grau/grau - gray - Das Auto ist grau.', 'literal': 'the gray/gray - gray - The car is gray.', 'english': 'gray - gray - The car is gray.'},
        {'german': 'das Rot/rot - red - Die Rose ist rot.', 'literal': 'the red/red - red - The rose is red.', 'english': 'red - red - The rose is red.'},
        {'german': 'das Blau/blau - blue - Die Jeans ist blau.', 'literal': 'the blue/blue - blue - The jeans is blue.', 'english': 'blue - blue - The jeans are blue.'},
        {'german': 'das Gelb/gelb - yellow - Die Sonne ist gelb.', 'literal': 'the yellow/yellow - yellow - The sun is yellow.', 'english': 'yellow - yellow - The sun is yellow.'},
        {'german': 'das Grün/grün - green - Das Gras ist grün.', 'literal': 'the green/green - green - The grass is green.', 'english': 'green - green - The grass is green.'},
        {'german': 'das Orange/orange - orange - Die Orange ist orange.', 'literal': 'the orange/orange - orange - The orange is orange.', 'english': 'orange - orange - The orange is orange.'},
        {'german': 'das Violett/violett - violet - Die Blume ist violett.', 'literal': 'the violet/violet - violet - The flower is violet.', 'english': 'violet - violet - The flower is violet.'},
        {'german': 'das Lila/lila - purple - Die Jacke ist lila.', 'literal': 'the purple/purple - purple - The jacket is purple.', 'english': 'purple - purple - The jacket is purple.'},
        {'german': 'das Braun/braun - brown - Der Bär ist braun.', 'literal': 'the brown/brown - brown - The bear is brown.', 'english': 'brown - brown - The bear is brown.'},
        {'german': 'das Pink/pink - pink - Die Bluse ist pink.', 'literal': 'the pink/pink - pink - The blouse is pink.', 'english': 'pink - pink - The blouse is pink.'},
        {'german': 'das Rosa/rosa - rose - Die Lippen sind rosa.', 'literal': 'the rose/rose - rose - The lips are rose.', 'english': 'rose - rose - The lips are rose.'},
      ],
    },
  };

  final List<Map<String, dynamic>> lessons = [
    {
      'name': 'Lektion 1',
      'pdf': 'App/Lektion_1/Lektion_1.pdf',
      'audio': [
        'App/Lektion_1/Tab 1_1 - Grußformeln und Befinden - informell.mp3',
        'App/Lektion_1/Tab 1_2 - Grußformeln und Befinden - formell.mp3',
        'App/Lektion_1/Tab 1_3 - Vorstellung - informell.mp3',
        'App/Lektion_1/Tab 1_4 - Vorstellung - formell.mp3',
        'App/Lektion_1/Tab 1_5 - Vorstellung - Alternative.mp3',
        'App/Lektion_1/Tab 1_8 - Ergänzung zum Dialog.mp3',
        'App/Lektion_1/Audio_E1_1.mp3',
        'App/Lektion_1/audio_1_6.mp3',
        'App/Lektion_1/audio_1_7.mp3',
      ],
    },
    {
      'name': 'Lektion 2',
      'pdf': 'App/Lektion_2/vt1_eBook_Lektion_2.pdf',
      'audio': [
        'App/Lektion_2/Audio 2_12 - Text - Ich bin Studentin.mp3',
        'App/Lektion_2/Audio E2_1.mp3',
        'App/Lektion_2/audio_2_11.mp3',
        'App/Lektion_2/Tab 2_1 - Regionale Begrüßungen - ugs.mp3',
        'App/Lektion_2/Tab 2_2 - Begrüßungen.mp3',
        'App/Lektion_2/Tab 2_3 - Alter und Hobbys - informell.mp3',
        'App/Lektion_2/Tab 2_4 - Alter und Hobbys - formell.mp3',
        'App/Lektion_2/Tab 2_5 - Arbeit - informell.mp3',
        'App/Lektion_2/Tab 2_6 - Arbeit - formell.mp3',
        'App/Lektion_2/Tab 2_7 - Studium - informell und formell.mp3',
        'App/Lektion_2/Tab 2_8 - Studium - Verneinung_arbeiten und studieren.mp3',
        'App/Lektion_2/Tab 2_9 - Berufliche Situation - Alternativen.mp3',
        'App/Lektion_2/Tab 2_10 - Elliptische Gegenfrage - informell und formell.mp3',
        'App/Lektion_2/Tab 2_13 - Verabschiedungen.mp3',
      ],
    },
    {
      'name': 'Lektion 3',
      'pdf': 'App/Lektion_3/vt1_eBook_Lektion_3.pdf',
      'audio': [
        'App/Lektion_3/Audio 3_7 - Text - Noch mal, bitte.mp3',
        'App/Lektion_3/Tab 3_1 - Sprachkenntnisse.mp3',
        'App/Lektion_3/Tab 3_2 - Sprachkenntnisse - Variationen.mp3',
        'App/Lektion_3/Tab 3_3 - Verständnisprobleme.mp3',
        'App/Lektion_3/Tab 3_4 - um Wiederholung bitten.mp3',
        'App/Lektion_3/Tab 3_5 - Entschuldigung als Ansprache.mp3',
        'App/Lektion_3/Tab 3_6 - Entschuldigung - Variationen.mp3',
      ],
    },
    {
      'name': 'Lektion 4',
      'pdf': 'App/Lektion_4/vt1_eBook_Lektion_4.pdf',
      'audio': [
        'App/Lektion_4/Audio 4_16 - Text - Kannst du mir kurz helfen.mp3',
        'App/Lektion_4/Audio 4_17 - Text - Wie kann ich Ihnen helfen.mp3',
        'App/Lektion_4/Tab 4_1 - ja, nein, vielleicht.mp3',
        'App/Lektion_4/Tab 4_2 - Bestätigung und Verneinung.mp3',
        'App/Lektion_4/Tab 4_3 - danke, bitte, gerne.mp3',
        'App/Lektion_4/Tab 4_4 - danke - Variationen.mp3',
        'App/Lektion_4/Tab 4_5 - bitte und gerne - Variationen.mp3',
        'App/Lektion_4/Tab 4_6 - Fahrkarte und Identifikation.mp3',
        'App/Lektion_4/Tab 4_7 - warten und folgen.mp3',
        'App/Lektion_4/Tab 4_8 - Hilfe anbieten.mp3',
        'App/Lektion_4/Tab 4_9 - um Hilfe bitten.mp3',
        'App/Lektion_4/Tab 4_10 - Orientierung und Verfügbarkeit.mp3',
        'App/Lektion_4/Tab 4_11 - Richtungsangaben.mp3',
        'App/Lektion_4/Tab 4_12 - Ortsangaben.mp3',
        'App/Lektion_4/Tab 4_13 - Preis.mp3',
        'App/Lektion_4/Tab 4_14 - kurze Bestätigung.mp3',
        'App/Lektion_4/Tab 4_15 - kurze Bestätigung ugs.mp3',
      ],
    },
    {
      'name': 'Lektion 5',
      'pdf': 'App/Lektion_5/vt1_eBook_Lektion_5.pdf',
      'audio': [
        'App/Lektion_5/Audio 5_21 - Text - Einen Tisch für zwei Personen bitte.mp3',
        'App/Lektion_5/Audio 5_22 - Text - Was darf ich Ihnen bringen.mp3',
        'App/Lektion_5/Audio 5_23 - Text - Die Rechnung bitte.mp3',
        'App/Lektion_5/Audio W5_1.mp3',
        'App/Lektion_5/Tab 5_1 - Nach einem Tisch fragen.mp3',
        'App/Lektion_5/Tab 5_2 - Tischreservierung.mp3',
        'App/Lektion_5/Tab 5_3 - Bestellung aufnehmen.mp3',
        'App/Lektion_5/Tab 5_4 - um ewas bitten und bestellen.mp3',
        'App/Lektion_5/Tab 5_5 - bestellen-Alternative.mp3',
        'App/Lektion_5/Tab 5_6 - bestellen mit nonverbaler Ergänzung.mp3',
        'App/Lektion_5/Tab 5_7 - weitere Bestellphrasen.mp3',
        'App/Lektion_5/Tab 5_8 - Spezifikationen - vor Ort oder zum Mitnehmen.mp3',
        'App/Lektion_5/Tab 5_9 - Spezifikationen - Getränkezusätze.mp3',
        'App/Lektion_5/Tab 5_10 - Wasserarten.mp3',
        'App/Lektion_5/Tab 5_11 - Alkoholische Getränke.mp3',
        'App/Lektion_5/Tab 5_12 - Bezahlprozess.mp3',
        'App/Lektion_5/Tab 5_13 - Trinkgeld geben.mp3',
        'App/Lektion_5/Tab 5_14 - Quittung.mp3',
        'App/Lektion_5/Tab 5_15 - sich höflich bedanken.mp3',
        'App/Lektion_5/Tab 5_16 - Toilette.mp3',
        'App/Lektion_5/Tab 5_17 - sich entschuldigen.mp3',
        'App/Lektion_5/Tab 5_18 - telefonisch Essen bestellen.mp3',
        'App/Lektion_5/Tab 5_19 - telefonisch Essen bestellen - Adresse angeben.mp3',
        'App/Lektion_5/Tab 5_20 - telefonisch Essen bestellen - Rückfragen und Hinweise.mp3',
      ],
    },
    {
      'name': 'Lektion 6',
      'pdf': 'App/Lektion_6/vt1_eBook_Lektion_6.pdf',
      'audio': [
        'App/Lektion_6/Audio 6_13 - Text - Wohin möchten Sie fahren.mp3',
        'App/Lektion_6/Audio 6_14 - Text - Wann kommt der nächste Bus.mp3',
        'App/Lektion_6/Audio W6_1.mp3',
        'App/Lektion_6/Tab 6_1 - Verkehrsmittel - Ich nehme.mp3',
        'App/Lektion_6/Tab 6_2 - Verkehrsmittel - Ich fahre mit.mp3',
        'App/Lektion_6/Tab 6_3 - Verkehrsmittel - zu Fuß und mit dem Flugzeug.mp3',
        'App/Lektion_6/Tab 6_4 - Orientierung und Ticketkauf.mp3',
        'App/Lektion_6/Tab 6_5 - richtiges Verkehrsmittel finden.mp3',
        'App/Lektion_6/Tab 6_6 - Ziel angeben.mp3',
        'App/Lektion_6/Tab 6_7 - um Auskunft bitten.mp3',
        'App/Lektion_6/Tab 6_8 - Verbindung und Umstieg.mp3',
        'App/Lektion_6/Tab 6_9 - Abfahrt und Ankunft.mp3',
        'App/Lektion_6/Tab 6_10 - Verspätung und Ausfall.mp3',
        'App/Lektion_6/Tab 6_11 - Ankunftszeit und Verspätung.mp3',
        'App/Lektion_6/Tab 6_12 - Zimmer buchen.mp3',
      ],
    },
    {
      'name': 'Lektion 7',
      'pdf': 'App/Lektion_7/vt1_eBook_Lektion_7.pdf',
      'audio': [
        'App/Lektion_7/Audio 7_10 - Text - Sie sind auch nicht von hier, oder.mp3',
        'App/Lektion_7/Tab 7_1 - Diskursmarker.mp3',
        'App/Lektion_7/Tab 7_2 - Pausenfüller.mp3',
        'App/Lektion_7/Tab 7_3 - Verständnissicherung.mp3',
        'App/Lektion_7/Tab 7_4 - Rückversicherung.mp3',
        'App/Lektion_7/Tab 7_5 - Unwissenheit ausdrücken.mp3',
        'App/Lektion_7/Tab 7_6 - Unwissenheit ausdrücken - Alternativen.mp3',
        'App/Lektion_7/Tab 7_7 - Bestätigungsfragen.mp3',
        'App/Lektion_7/Tab 7_8 - Bestätigung und Zustimmung.mp3',
        'App/Lektion_7/Tab 7_9 - Verneinung und Korrektur.mp3',
      ],
    },
    {
      'name': 'Lektion 8',
      'pdf': 'App/Lektion_8/vt1_eBook_Lektion_8.pdf',
      'audio': [
        'App/Lektion_8/Audio 8_21 - Text - Wo ist das Fundbüro.mp3',
        'App/Lektion_8/Audio 8_22 - Text - Meine Sachen sind weg.mp3',
        'App/Lektion_8/Tab 8_1 - Warnhinweise.mp3',
        'App/Lektion_8/Tab 8_2 - Warnrufe.mp3',
        'App/Lektion_8/Tab 8_3 - Hilfe rufen.mp3',
        'App/Lektion_8/Tab 8_4 - Hilfe anbieten.mp3',
        'App/Lektion_8/Tab 8_5 - auf Hilfsangebote reagieren.mp3',
        'App/Lektion_8/Tab 8_6 - um Auskunft bitten.mp3',
        'App/Lektion_8/Tab 8_7 - um Auskunft bitten - Gibt es hier.mp3',
        'App/Lektion_8/Tab 8_8 - keine Auskunft.mp3',
        'App/Lektion_8/Tab 8_9 - auf keine Auskunft reagieren.mp3',
        'App/Lektion_8/Tab 8_10 - Handy aufladen.mp3',
        'App/Lektion_8/Tab 8_11 - Telefon benutzen.mp3',
        'App/Lektion_8/Tab 8_12 - Akku leer.mp3',
        'App/Lektion_8/Tab 8_13 - Verlust melden.mp3',
        'App/Lektion_8/Tab 8_14 - Verlust melden - Alternative 1.mp3',
        'App/Lektion_8/Tab 8_15 - Verlust melden - Alternative 2.mp3',
        'App/Lektion_8/Tab 8_16 - Diebstahl melden.mp3',
        'App/Lektion_8/Tab 8_17 - Überforderung ausdrücken.mp3',
        'App/Lektion_8/Tab 8_18 - Notruf veranlassen.mp3',
        'App/Lektion_8/Tab 8_19 - Notrufnummern im DACH-Raum.mp3',
        'App/Lektion_8/Tab 8_20 - Euronotrufnummer.mp3',
      ],
    },
    {
      'name': 'Lektion 9',
      'pdf': 'App/Lektion_9/vt1_eBook_Lektion_9.pdf',
      'audio': [
        'App/Lektion_9/Audio 9_9 - Text - Ihre Adresse bitte.mp3',
        'App/Lektion_9/Tab 9_1 - Wohnadresse und Kontaktdaten.mp3',
        'App/Lektion_9/Tab 9_2 - Wohnadresse und Kontaktdaten - Alternative.mp3',
        'App/Lektion_9/Tab 9_3 - Geburtsdatum.mp3',
        'App/Lektion_9/Tab 9_4 - Geburtstag.mp3',
        'App/Lektion_9/Tab 9_5 - Familienstand.mp3',
        'App/Lektion_9/Tab 9_6 - Kinder.mp3',
        'App/Lektion_9/Tab 9_7 - Geschwister.mp3',
        'App/Lektion_9/Tab 9_8 - Haustiere.mp3',
      ],
    },
    {
      'name': 'Lektion 10',
      'pdf': 'App/Lektion_10/vt1_eBook_Lektion_10.pdf',
      'audio': [
        'App/Lektion_10/Audio W1.mp3',
      ],
    },
    {
      'name': 'Lektion 11',
      'pdf': 'App/Lektion_11/vt1_eBook_Lektion_11.pdf',
      'audio': [
        'App/Lektion_11/Audio 11_10 - Text - Wie lange bist du schon hier.mp3',
        'App/Lektion_11/Tab 11_1 - Aufenthaltsdauer.mp3',
        'App/Lektion_11/Tab 11_2 - Aufenthaltsdauer - regionale Variante.mp3',
        'App/Lektion_11/Tab 11_3 - Geplanter Aufenthalt.mp3',
        'App/Lektion_11/Tab 11_4 - vergangene Reisen.mp3',
        'App/Lektion_11/Tab 11_5 - besuchte Orte.mp3',
        'App/Lektion_11/Tab 11_6 - Grund des Aufenthalts erfragen.mp3',
        'App/Lektion_11/Tab 11_7 - Grund des Aufenthalts angeben.mp3',
        'App/Lektion_11/Tab 11_8 - Grund des Aufenthalts angeben und erfragen - Alternative.mp3',
        'App/Lektion_11/Tab 11_9 - Grund des Aufenthalts - verkürzt.mp3',
      ],
    },
    {
      'name': 'Lektion 12',
      'pdf': 'App/Lektion_12/vt1_eBook_Lektion_12.pdf',
      'audio': [
        'App/Lektion_12/Audio 12_6 - Text - Wo waren Sie schon überall.mp3',
        'App/Lektion_12/Audio 12_7 - Text - Du bist neu hier, ja.mp3',
        'App/Lektion_12/Tab 12_1 - Meinung zum Aufenthalt.mp3',
        'App/Lektion_12/Tab 12_2 - Gefallen ausdrücken.mp3',
        'App/Lektion_12/Tab 12_3 - über das Deutschlernen sprechen.mp3',
        'App/Lektion_12/Tab 12_4 - über Deutschkenntnisse sprechen.mp3',
        'App/Lektion_12/Tab 12_5 - über besuchte Orte sprechen.mp3',
      ],
    },
    {
      'name': 'Lektion 13',
      'pdf': 'App/Lektion_13/vt1_eBook_Lektion_13.pdf',
      'audio': [
        'App/Lektion_13/Audio 13_6 - Text - Was machst du gerne in deiner Freizeit.mp3',
        'App/Lektion_13/Tab 13_1 Hobbys nennen - Ich gehe gerne.mp3',
        'App/Lektion_13/Tab 13_2 Hobbys nennen - Ich spiele gerne.mp3',
        'App/Lektion_13/Tab 13_3 Hobbys nennen - Ich mache gerne.mp3',
        'App/Lektion_13/Tab 13_4 Hobbys nennen - Ich verbringe gerne Zeit.mp3',
        'App/Lektion_13/Tab 13_5 nach Hobbys fragen.mp3',
      ],
    },
    {
      'name': 'Lektion 14',
      'pdf': 'App/Lektion_14/vt1_eBook_Lektion_14.pdf',
      'audio': [
        'App/Lektion_14/Audio 14_14 - Text - Siehst du gerne Filme.mp3',
        'App/Lektion_14/Audio 14_15 - Text - Das Restaurant heißt Roter Hummer.mp3',
        'App/Lektion_14/Tab 14_1 - Vorlieben ausdrücken - Filme und Serien.mp3',
        'App/Lektion_14/Tab 14_2 - Vorlieben ausdrücken - Essen.mp3',
        'App/Lektion_14/Tab 14_3 - Ernährungsweise angeben.mp3',
        'App/Lektion_14/Tab 14_4 - Lieblingsdinge nennen - Bücher.mp3',
        'App/Lektion_14/Tab 14_5 - Lieblingsdinge nennen - Essen.mp3',
        'App/Lektion_14/Tab 14_6 - Meinung ausdrücken mit gefallen.mp3',
        'App/Lektion_14/Tab 14_7 - Meinung ausdrücken mit schmecken.mp3',
        'App/Lektion_14/Tab 14_8 - Gefallen ausdrücken.mp3',
        'App/Lektion_14/Tab 14_9 - Gefallen ausdrücken mit Adjektiven.mp3',
        'App/Lektion_14/Tab 14_10 - Gefallen ausdrücken mit Adjektiven ugs.mp3',
        'App/Lektion_14/Tab 14_11 - Reaktion auf Aussagen und Vorschläge.mp3',
        'App/Lektion_14/Tab 14_12 - Missfallen und Unzufriedenheit ausdrücken.mp3',
        'App/Lektion_14/Tab 14_13 - Graduierung von Meinungen.mp3',
      ],
    },
    {
      'name': 'Lektion 15',
      'pdf': 'App/Lektion_15/vt1_eBook_Lektion_15.pdf',
      'audio': [
        'App/Lektion_15/Audio 15_11 - Text - Ich koche fast nie.mp3',
        'App/Lektion_15/Audio 15_12 - Text - Ein-bis zweimal in der Woche.mp3',
        'App/Lektion_15/Tab 15_1 - Aktionen einleiten.mp3',
        'App/Lektion_15/Tab 15_2 - Antworten zwischen Ja und Nein.mp3',
        'App/Lektion_15/Tab 15_3 - Häufigkeit und Regelmäßigkeit.mp3',
        'App/Lektion_15/Tab 15_4 - Gegenfragen bei Überraschung.mp3',
        'App/Lektion_15/Tab 15_5 - Sätze zur Beruhigung.mp3',
        'App/Lektion_15/Tab 15_6 - Emotionale Bewertung.mp3',
        'App/Lektion_15/Tab 15_7 - Gleichgültigkeit ausdrücken.mp3',
        'App/Lektion_15/Tab 15_8 - Gleichgültigkeit ausdrücken - Alternativen.mp3',
        'App/Lektion_15/Tab 15_9 - Floskeln und Redewendungen.mp3',
        'App/Lektion_15/Tab 15_10 - Aktionen einleiten und Aussagen kommentieren.mp3',
      ],
    },
    {
      'name': 'Lektion 16',
      'pdf': 'App/Lektion_16/vt1_eBook_Lektion_16.pdf',
      'audio': [
        'App/Lektion_16/Audio 16_10 - Text - Hast du am Sonntag Zeit.mp3',
        'App/Lektion_16/Audio 16_11 - Text - Was machst du am Wochenende.mp3',
        'App/Lektion_16/Tab 16_1 - Aktivitäten vorschlagen - Hast du Lust.mp3',
        'App/Lektion_16/Tab 16_2 - Aktivitäten vorschlagen - Wollen wir.mp3',
        'App/Lektion_16/Tab 16_3 - Aktivitäten vorschlagen - Gehen wir.mp3',
        'App/Lektion_16/Tab 16_4 - Verfügbarkeit und Uhrzeit nennen und erfragen.mp3',
        'App/Lektion_16/Tab 16_5 - Treffpunkt vorschlagen und erfragen.mp3',
        'App/Lektion_16/Tab 16_6 - Treffen zusagen,verschieben und absagen.mp3',
        'App/Lektion_16/Tab 16_7 - über das Wetter sprechen.mp3',
        'App/Lektion_16/Tab 16_8 - Wetterphänomene nennen.mp3',
        'App/Lektion_16/Tab 16_9 - Angaben zur Temperatur.mp3',
      ],
    },
    {
      'name': 'Lektion 17',
      'pdf': 'App/Lektion_17/vt1_eBook_Lektion_17.pdf',
      'audio': [
        'App/Lektion_17/Audio 17_14 - Text - Wie ist der Name.mp3',
        'App/Lektion_17/Audio 17_15 - Text - Was machst du am Samstag.mp3',
        'App/Lektion_17/Tab 17_1 - Termine vereinbaren.mp3',
        'App/Lektion_17/Tab 17_2 - Terminvorschlag zusagen und ablehnen.mp3',
        'App/Lektion_17/Tab 17_3 - Wochenabschnitte.mp3',
        'App/Lektion_17/Tab 17_4 - Wochentage.mp3',
        'App/Lektion_17/Tab 17_5 - Tageszeiten.mp3',
        'App/Lektion_17/Tab 17_6 - Tageszeiten als Adverbien.mp3',
        'App/Lektion_17/Tab 17_7 - Wochentage als Adverbien.mp3',
        'App/Lektion_17/Tab 17_8 - Uhrzeit erfragen und angeben.mp3',
        'App/Lektion_17/Tab 17_9 - Uhrzeit nennen.mp3',
        'App/Lektion_17/Tab 17_10 - Uhrzeit nennen - 24-Stunden-System.mp3',
        'App/Lektion_17/Tab 17_11 - Uhrzeit mit Tageszeit nennen.mp3',
        'App/Lektion_17/Tab 17_12 - Zeitpunkt erfragen und angeben.mp3',
        'App/Lektion_17/Tab 17_13 - Zeiteinheiten - Sekunde, Minute, Stunde.mp3',
      ],
    },
    {
      'name': 'Lektion 18',
      'pdf': 'App/Lektion_18/vt1_eBook_Lektion_18.pdf',
      'audio': [
        'App/Lektion_18/Audio 18_10 - Text - Zahnarztpraxis Weiß, Sie sprechen mit Frau Weber.mp3',
        'App/Lektion_18/Tab 18_1 - Telefonieren_Begrüßung.mp3',
        'App/Lektion_18/Tab 18_2 - Telefonieren_Begrüßungsformeln.mp3',
        'App/Lektion_18/Tab 18_3 - Telefonieren_Verabschiedung.mp3',
        'App/Lektion_18/Tab 18_4 - Telefonieren_Dank und Abschluss.mp3',
        'App/Lektion_18/Tab 18_5 - Formeller Schriftverkehr - Begrüßung.mp3',
        'App/Lektion_18/Tab 18_6 - Formeller Schriftverkehr - Verabschiedung.mp3',
        'App/Lektion_18/Tab 18_7 - Informeller Schriftverkehr - Begrüßung.mp3',
        'App/Lektion_18/Tab 18_8 - Informeller Schriftverkehr - Verabschiedung.mp3',
        'App/Lektion_18/Tab 18_9 - Abkürzungen in der geschriebenen Sprache.mp3',
      ],
    },
    {
      'name': 'Lektion 19',
      'pdf': 'App/Lektion_19/vt1_eBook_Lektion_19.pdf',
      'audio': [
        'App/Lektion_19/Audio 19_11 - Text - Ich habe Fieber und Husten.mp3',
        'App/Lektion_19/Tab 19_1 - Allgemeines Befinden erfragen und ausdrücken.mp3',
        'App/Lektion_19/Tab 19_2 - Allgemeines Befinden - differenzierte Angabe.mp3',
        'App/Lektion_19/Tab 19_3 - Beschwerden erfragen.mp3',
        'App/Lektion_19/Tab 19_4 - Psychisches Befinden ausdrücken.mp3',
        'App/Lektion_19/Tab 19_5 - Physisches Befinden ausdrücken.mp3',
        'App/Lektion_19/Tab 19_6 - Krankheit und Beschwerden nennen.mp3',
        'App/Lektion_19/Tab 19_7 - Beschwerden benennen - Ich habe -schmerzen.mp3',
        'App/Lektion_19/Tab 19_8 - Beschwerden benennen - tut, tun weh.mp3',
        'App/Lektion_19/Tab 19_9 - Krankheiten und Symptome benennen.mp3',
        'App/Lektion_19/Tab 19_10 - Genesungswünsche.mp3',
      ],
    },
    {
      'name': 'Lektion 20',
      'pdf': 'App/Lektion_20/vt1_eBook_Lektion_20.pdf',
      'audio': [
        'App/Lektion_20/Audio 20_10 - Text - Komm rein.mp3',
        'App/Lektion_20/Audio 20_11 - Text - Wie gefällt Ihnen die Wohnung.mp3',
        'App/Lektion_20/Tab 20_1 - Wohnsituation beschreiben.mp3',
        'App/Lektion_20/Tab 20_2 - vorübergehende Wohnsituation beschreiben.mp3',
        'App/Lektion_20/Tab 20_3 - Wohnsituation beschreiben_Wir-Form.mp3',
        'App/Lektion_20/Tab 20_4 - Details zur Wohnsituation angeben.mp3',
        'App/Lektion_20/Tab 20_5 - Hausarbeiten nennen.mp3',
        'App/Lektion_20/Tab 20_6 - Probleme im Haushalt melden.mp3',
        'App/Lektion_20/Tab 20_7 - Besuch empfangen.mp3',
        'App/Lektion_20/Tab 20_8 - Besuch bewirten.mp3',
        'App/Lektion_20/Tab 20_9 - Wohnungsführung.mp3',
      ],
    },
    {
      'name': 'Anhang Referenzlisten',
      'pdf': 'App/Anhang_Referenzlisten/vt1_eBook_Anhang.pdf',
      'audio': [
        'App/Anhang_Referenzlisten/Ref_1 - Alphabet und Buchstabiertafel.mp3',
        'App/Anhang_Referenzlisten/Ref_2 - Ländernamen.mp3',
        'App/Anhang_Referenzlisten/Ref_3 - Städtenamen.mp3',
        'App/Anhang_Referenzlisten/Ref_4 - Berufsbezeichnungen.mp3',
        'App/Anhang_Referenzlisten/Ref_5 - Kardinalzahlen.mp3',
        'App/Anhang_Referenzlisten/Ref_6 - Ordinalzahlen.mp3',
        'App/Anhang_Referenzlisten/Ref_7 - Monatsnamen.mp3',
        'App/Anhang_Referenzlisten/Ref_8 - Farben.mp3',
      ],
    },
    {
      'name': 'Losungen',
      'pdf': 'App/Losungen/vt1_eBook_Losungen.pdf',
      'audio': [],
    },
    {
      'name': 'Titelei und IHV',
      'pdf': 'App/Titelei und IHV/vt1_eBook_Titelei_IHV.pdf',
      'audio': [],
    },
    {
      'name': 'Wiederholung und Sprechtraining',
      'pdf': 'App/Wiederholung_und_Sprechtraining/vt1_eBook_Wiederholung_und_Sprechtraining.pdf',
      'audio': [
        'App/Wiederholung_und_Sprechtraining/Audio ST01.mp3',
        'App/Wiederholung_und_Sprechtraining/Audio ST02.mp3',
        'App/Wiederholung_und_Sprechtraining/Audio W2.mp3',
      ],
    },
  ];



  // Convert lesson data to Lesson model
  Lesson _convertToLessonModel(Map<String, dynamic> lessonData) {
    return Lesson(
      name: lessonData['name'],
      pdf: lessonData['pdf'],
      audio: List<String>.from(lessonData['audio'] ?? []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Title
              Container(
                margin: const EdgeInsets.only(top: 40, bottom: 20),
                child: Text(
                  '| LEICHT-ERLERNEN |',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3b3ec3),
                    letterSpacing: 1.2,
                  ),
                ),
              ),



              // Lessons List
              Expanded(
                child: ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lesson name
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              lesson['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3b3ec3),
                              ),
                            ),
                          ),
                          // Buttons row
                          Row(
                            children: [
                              // Download Manager (Compact Mode)
                              Expanded(
                                flex: 2,
                                child: DownloadManager(
                                  lesson: _convertToLessonModel(lesson),
                                  compact: true, // Use compact mode
                                  onDownloadComplete: () {
                                    // Refresh UI after download
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // View button
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LessonDetailPage(
                                          lessonName: lesson['name'],
                                          pdfPath: lesson['pdf'],
                                          audioFiles: List<String>.from(lesson['audio']),
                                          audioContent: audioContent,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF3b3ec3),
                                    side: BorderSide(
                                      color: const Color(0xFF3b3ec3),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.visibility, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Debug button at bottom (hidden)
              // Container(
              //   margin: const EdgeInsets.only(top: 20),
              //   child: TextButton(
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => const DebugPage()),
              //       );
              //     },
              //     child: Text(
              //       'Debug Info',
              //       style: TextStyle(
              //         color: const Color(0xFF3b3ec3).withOpacity(0.7),
              //         fontSize: 14,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonDetailPage extends StatelessWidget {
  final String lessonName;
  final String pdfPath;
  final List<String> audioFiles;
  final Map<String, Map<String, dynamic>>? audioContent;

  const LessonDetailPage({
    super.key,
    required this.lessonName,
    required this.pdfPath,
    required this.audioFiles,
    this.audioContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Back Button and Title Row
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3b3ec3),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 80),
                      child: Text(
                        lessonName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3b3ec3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Empty container to balance the back button
                  const SizedBox(width: 56),
                ],
              ),

                             // Audioplayer Button
               Container(
                 width: double.infinity,
                 margin: const EdgeInsets.only(bottom: 20),
                 child: ElevatedButton(
                   onPressed: () {
                                               Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioOptionsPage(
                                lessonName: lessonName,
                                audioFiles: audioFiles,
                                audioContent: this.audioContent,
                              ),
                            ),
                          );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF3b3ec3),
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                     padding: const EdgeInsets.symmetric(
                       vertical: 20,
                       horizontal: 20,
                     ),
                     elevation: 0,
                   ),
                   child: const Text(
                     'Audioplayer',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
               ),

               // eBook Button
               Container(
                 width: double.infinity,
                 margin: const EdgeInsets.only(bottom: 20),
                 child: ElevatedButton(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => PDFViewPage(
                           pdfAssetPath: pdfPath,
                           lessonName: lessonName,
                         ),
                       ),
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF3b3ec3),
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                     padding: const EdgeInsets.symmetric(
                       vertical: 20,
                       horizontal: 20,
                     ),
                     elevation: 0,
                   ),
                   child: const Text(
                     'eBook',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioPlayerPage extends StatefulWidget {
  final String lessonName;
  final List<String> audioFiles;
  final Map<String, Map<String, dynamic>>? audioContent;
  final String audioType; // Add audio type parameter

  const AudioPlayerPage({
    super.key,
    required this.lessonName,
    required this.audioFiles,
    this.audioContent,
    required this.audioType, // Add required parameter
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isPlaying = false;
  String? _audioError;
  int? _currentAudioIndex;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _audioPlayer.onDurationChanged.listen((d) {
        setState(() => _audioDuration = d);
      });
      _audioPlayer.onPositionChanged.listen((p) {
        setState(() => _audioPosition = p);
      });
      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          // Reset current audio index when audio completes
          if (state == PlayerState.completed) {
            _currentAudioIndex = null;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio(String audioPath, int index) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio wird nur auf Mobilgeräten unterstützt')),
      );
    } else {
      try {
        setState(() {
          _audioError = null;
        });

        // Get local file path using FileHandler
        final localPath = await FileHandler.getAudioPath(audioPath, context);
        if (localPath == null) {
          return; // Error dialog already shown by FileHandler
        }

        // If clicking the same audio that's currently playing, toggle pause/resume
        if (_currentAudioIndex == index && _isPlaying) {
          await _audioPlayer.pause();
          setState(() {
            _isPlaying = false;
          });
        } else {
          // If clicking a different audio or resuming, play it
          if (_currentAudioIndex != index) {
            await _audioPlayer.stop();
            setState(() {
              _currentAudioIndex = index;
            });
          }
          
          // Use DeviceFileSource for local files
          await _audioPlayer.play(DeviceFileSource(localPath));
          setState(() {
            _isPlaying = true;
          });
        }
      } catch (e) {
        setState(() { _audioError = 'Fehler beim Abspielen: $e'; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Abspielen: $e')),
        );
      }
    }
  }

  void _stopAudio() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio wird nur auf Mobilgeräten unterstützt')),
      );
    } else {
      try {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Stoppen: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  Widget _buildContentTable(Map<String, dynamic> content) {
    final List<Map<String, String>> phrases = List<Map<String, String>>.from(
      content['phrases'] ?? []
    );

    if (phrases.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        children: [
          // Table header
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'German',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Literal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'English',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Table rows with alternating colors
          ...phrases.asMap().entries.map((entry) {
            final index = entry.key;
            final phrase = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      phrase['german'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      phrase['literal'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      phrase['english'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.lessonName} - ${widget.audioType}'),
        backgroundColor: const Color(0xFF3b3ec3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_audioError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _audioError!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: widget.audioFiles.isEmpty
                ? const Center(
                    child: Text(
                      'Keine Audiodateien verfügbar',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.audioFiles.length,
                    itemBuilder: (context, index) {
                      final audio = widget.audioFiles[index];
                      final audioName = audio.split('/').last.replaceAll('.mp3', '');
                      final isCurrent = index == _currentAudioIndex;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent ? const Color(0xFF3b3ec3) : Colors.grey.shade300,
                            width: isCurrent ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Audio title without icon
                              Text(
                                audioName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent ? const Color(0xFF3b3ec3) : Colors.black87,
                                ),
                              ),
                              // Play button at the top (simplified)
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _playAudio(audio, index),
                                icon: Icon(_isPlaying && isCurrent ? Icons.pause : Icons.play_arrow),
                                label: Text(_isPlaying && isCurrent ? 'Pause' : 'Abspielen'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3b3ec3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              // Display content table if available (moved below audio controls)
                              if (widget.audioContent != null &&
                                  widget.audioContent!.containsKey(audioName)) ...[
                                _buildContentTable(widget.audioContent![audioName]!),
                                const SizedBox(height: 16),
                              ],
                              // Stop button (only show when audio is playing)
                              if (isCurrent && _isPlaying) ...[
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _stopAudio,
                                  icon: const Icon(Icons.stop),
                                  label: const Text('Stopp'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PDFViewPage extends StatelessWidget {
  final String pdfAssetPath;
  final String lessonName;
  const PDFViewPage({super.key, required this.pdfAssetPath, required this.lessonName});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text('$lessonName - eBook'),
          backgroundColor: const Color(0xFF3b3ec3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('PDF-Anzeige nur auf Mobilgeräten unterstützt')),
      );
    } else {
      // Mobile: sử dụng FileHandler để load PDF từ local storage
      return Scaffold(
        body: FutureBuilder<String?>(
          future: FileHandler.getPdfPath(pdfAssetPath, context),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Fehler: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Zurück'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text('PDF-Datei nicht gefunden'),
                    const SizedBox(height: 8),
                    Text(
                      'Bitte laden Sie die Lektion herunter',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Zurück'),
                    ),
                  ],
                ),
              );
            }
            return CrossPlatformPdfViewer(
              filePath: snapshot.data!,
              title: '$lessonName - eBook',
            );
          },
        ),
      );
    }
  }
}

class AudioOptionsPage extends StatelessWidget {
  final String lessonName;
  final List<String> audioFiles;
  final Map<String, Map<String, dynamic>>? audioContent;

  const AudioOptionsPage({
    super.key,
    required this.lessonName,
    required this.audioFiles,
    this.audioContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Back Button and Title Row
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3b3ec3),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 80),
                      child: Text(
                        lessonName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3b3ec3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Empty container to balance the back button
                  const SizedBox(width: 56),
                ],
              ),

              // Tabellen/Wortlisten Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Filter audio files for Tabellen/Wortlisten - show files starting with "Tab " or all files for Anhang Referenzlisten
                    List<String> filteredAudioFiles = audioFiles.where((file) =>
                      file.contains('Tab ') || lessonName == 'Anhang Referenzlisten'
                    ).toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayerPage(
                          lessonName: lessonName,
                          audioFiles: filteredAudioFiles,
                          audioContent: audioContent,
                          audioType: 'Tabellen/Wortlisten',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3b3ec3),
                    side: BorderSide(
                      color: const Color(0xFF3b3ec3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tabellen/Wortlisten',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Hörbeispiele Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Filter audio files for Hörbeispiele - show files with pattern "audio_X_Y.mp3" or "Audio X_Y" (but not for Anhang Referenzlisten)
                    List<String> filteredAudioFiles = lessonName == 'Anhang Referenzlisten'
                      ? <String>[]
                      : audioFiles.where((file) =>
                          (file.contains('audio_') && file.contains('.mp3')) ||
                          (file.contains('Audio ') && file.contains('_') && !file.contains('Audio_E') && !file.contains('Audio W'))
                        ).toList();

                    if (filteredAudioFiles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Keine Hörbeispiele verfügbar')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPlayerPage(
                            lessonName: lessonName,
                            audioFiles: filteredAudioFiles,
                            audioContent: audioContent,
                            audioType: 'Hörbeispiele',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3b3ec3),
                    side: BorderSide(
                      color: const Color(0xFF3b3ec3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Hörbeispiele',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Übungsaudios Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Filter audio files for Übungsaudios - show files with pattern "Audio_EX_X.mp3" or "Audio WX_X.mp3" (but not for Anhang Referenzlisten)
                    List<String> filteredAudioFiles = lessonName == 'Anhang Referenzlisten'
                      ? <String>[]
                      : audioFiles.where((file) =>
                          (file.contains('Audio_E') && file.contains('.mp3')) ||
                          (file.contains('Audio W') && file.contains('.mp3'))
                        ).toList();

                    if (filteredAudioFiles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Keine Übungsaudios verfügbar')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPlayerPage(
                            lessonName: lessonName,
                            audioFiles: filteredAudioFiles,
                            audioContent: audioContent,
                            audioType: 'Übungsaudios',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3b3ec3),
                    side: BorderSide(
                      color: const Color(0xFF3b3ec3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Übungsaudios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}