require 'rietveld_easytrack/configuration'
require 'rietveld_easytrack/version'
require 'nokogiri'
require 'hash_validator'

require 'rietveld_easytrack/connection'
require 'rietveld_easytrack/task_management'
require 'rietveld_easytrack/text_messaging'
require 'rietveld_easytrack/activity_registration'

require 'local_config' if File.file?('lib/local_config.rb')

module RietveldEasytrack
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.root
    File.expand_path('../..',__FILE__)
  end

  def self.types
    {
      10 => 'Rijden',
      11 => 'File',
      12 => 'Onbepaald',
      13 => 'Inloggen',
      14 => 'Uitloggen',
      15 => 'Nieuwe rit',
      16 => 'Rit gefaald',
      17 => 'Locatie gefaald',
      18 => 'Taak gefaald',
      20 => 'Overnachten',
      21 => 'Pauze',
      22 => 'Rusten',
      25 => 'Douane',
      26 => 'Grens',
      27 => 'Melden',
      28 => 'Kantoor',
      29 => 'Wachten',
      30 => 'Standplaats',
      31 => 'Tanken',
      32 => 'Gas meten',
      33 => 'Wegen',
      40 => 'Laden',
      41 => 'Laden (VIA TAAK)',
      44 => 'Laden standplaats',
      45 => 'Laden standplaats (VIA TAAK)',
      46 => 'Container laden',
      47 => 'Container laden (VIA TAAK)',
      48 => 'Opzetten',
      49 => 'Opzetten (VIA TAAK)',
      50 => 'Lossen',
      51 => 'Lossen (VIA TAAK)',
      54 => 'Lossen standplaats',
      55 => 'Lossen standplaats (VIA TAAK)',
      56 => 'Container lossen',
      57 => 'Container lossen (VIA TAAK)',
      58 => 'Afzetten',
      59 => 'Afzetten (VIA TAAK)',
      60 => 'Koppelen',
      61 => 'Koppelen (VIA TAAK)',
      62 => 'Aankoppelen',
      63 => 'Aankoppelen (VIA TAAK)',
      64 => 'Afkoppelen',
      65 => 'Afkoppelen (VIA TAAK)',
      66 => 'Wisselen',
      67 => 'Wisselen (VIA TAAK)',
      80 => 'Onderhoud',
      81 => 'Reparatie',
      82 => 'Pech',
      83 => 'Wassen',
      84 => 'Truckwash',
      86 => 'Reinigen',
      87 => 'Reinigen (VIA TAAK)',
      88 => 'Spoelen',
      89 => 'Spoelen (VIA TAAK)',
      90 => 'Boot',
      91 => 'Boot (VIA TAAK)',
      92 => 'Trein',
      93 => 'Trein (VIA TAAK)',
      94 => 'Opmerking',
      95 => 'Prive',
      96 => 'Rangeren',
      97 => 'Spanbanden',
      98 => 'Papieren',
      99 => 'Diversen',
      200 => 'Onkosten',
      221 => 'Overpompen',
      256 => 'Laden gmp (VIA TAAK)',
      257 => 'Lossen gmp (VIA TAAK)',
      258 => 'Laden mest (VIA TAAK)',
      259 => 'Lossen mest (VIA TAAK)'
    }
  end
end
