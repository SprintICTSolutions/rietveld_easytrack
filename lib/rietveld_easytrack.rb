require "rietveld_easytrack/version"
require "nokogiri"
require "hash_validator"

require "rietveld_easytrack/scp.rb"
require "rietveld_easytrack/task_management"
require "rietveld_easytrack/text_messaging"

module RietveldEasytrack

  TYPES = {
    10 => 'rijden',
    11 => 'file',
    12 => 'onbepaald',
    13 => 'inloggen',
    14 => 'uitloggen',
    15 => 'nieuwe rit',
    16 => 'rit gefaald',
    17 => 'locatie gefaald',
    18 => 'taak gefaald',
    20 => 'overnachten',
    21 => 'pauze',
    22 => 'rusten',
    25 => 'douane',
    26 => 'grens',
    27 => 'melden',
    28 => 'kantoor',
    29 => 'wachten',
    30 => 'standplaats',
    31 => 'tanken',
    32 => 'gas meten',
    33 => 'wegen',
    40 => 'laden',
    41 => 'laden (VIA TAAK)',
    44 => 'laden standplaats',
    45 => 'laden standplaats (VIA TAAK)',
    46 => 'container laden',
    47 => 'container laden (VIA TAAK)',
    48 => 'opzetten',
    49 => 'opzetten (VIA TAAK)',
    50 => 'lossen',
    51 => 'lossen (VIA TAAK)',
    54 => 'lossen standplaats',
    55 => 'lossen standplaats (VIA TAAK)',
    56 => 'container lossen',
    57 => 'container lossen (VIA TAAK)',
    58 => 'afzetten',
    59 => 'afzetten (VIA TAAK)',
    60 => 'koppelen',
    61 => 'koppelen (VIA TAAK)',
    62 => 'aankoppelen',
    63 => 'aankoppelen (VIA TAAK)',
    64 => 'afkoppelen',
    65 => 'afkoppelen (VIA TAAK)',
    66 => 'wisselen',
    67 => 'wisselen (VIA TAAK)',
    80 => 'onderhoud',
    81 => 'reparatie',
    82 => 'pech',
    83 => 'wassen',
    84 => 'truckwash',
    86 => 'reinigen',
    87 => 'reinigen (VIA TAAK)',
    88 => 'spoelen',
    89 => 'spoelen (VIA TAAK)',
    90 => 'boot',
    91 => 'boot (VIA TAAK)',
    92 => 'trein',
    93 => 'trein (VIA TAAK)',
    94 => 'opmerking',
    95 => 'prive',
    96 => 'rangeren',
    97 => 'spanbanden',
    98 => 'papieren',
    99 => 'diversen',
    200 => 'onkosten'
  }


  def self.root
    File.expand_path('../..',__FILE__)
  end

  def self.types
    TYPES
  end

  def self.connect

  end
end
