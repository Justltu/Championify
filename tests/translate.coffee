should = require('chai').should()
glob = require 'glob'
_ = require 'lodash'
Translate = require '../lib/translate'

riot_locales = {
  bg: 'bg_BG'
  cs: 'cs_CZ'
  de: 'de_DE'
  el: 'el_GR'
  en: 'en_US'
  es: 'es_ES'
  fr: 'fr_FR'
  hu: 'hu_HU'
  id: 'id_ID'
  it: 'it_IT'
  ja: 'ja_JP'
  ko: 'ko_KR'
  nl: 'nl_NL'
  ms: 'ms_MY'
  pl: 'pl_PL'
  pt: 'pt_BR'
  'pt-BR': 'pt_BR'
  ro: 'ro_RO'
  ru: 'ru_RU'
  th: 'th_TH'
  tr: 'tr_TR'
  vi: 'vn_VN'
  'zh-CN': 'zh_CN'
  'zh-TW': 'zh_TW'
}

flags = {
  bg: 'bg'
  bs: 'ba'
  ca: 'es'
  cs: 'cz'
  da: 'dk'
  de: 'de'
  el: 'gr'
  en: 'gb'
  es: 'es'
  fi: 'fi'
  fr: 'fr'
  he: 'il'
  hr: 'hr'
  hu: 'hu'
  id: 'id'
  it: 'it'
  ja: 'jp'
  ka: 'ge'
  ko: 'kr'
  lt: 'lt'
  lv: 'lv'
  no: 'no'
  nl: 'nl'
  ms: 'my'
  pl: 'pl'
  pt: 'pt'
  'pt-BR': 'br'
  ro: 'ro'
  ru: 'ru'
  sl: 'si'
  sk: 'sk'
  sr: 'cs'
  sv: 'se'
  th: 'th'
  tr: 'tr'
  vi: 'vn'
  'zh-CN': 'cn'
  'zh-TW': 'tw'
}

count = null

describe 'lib/translate.coffee', ->
  before ->
    window.T = new Translate('ko')

    # Minus _source
    count = glob.sync('./i18n/*.json').length - 1

  it 'should have the same amount of locales and flags', ->
    _.size(flags).should.equal(count)

  it 'should return the set locale', ->
    T.locale.should.equal('ko')

  it 'should merge phrases', ->
    T.merge({test_phrase: '123'})

  it 'should return merged phrase', ->
    T.t('test_phrase').should.equal('123')

  it 'should throw an error when a phrase doesn\'t exist', ->
    try
      T.t('blahblah')
    catch e
      should.exist(e)

  it 'should throw an error when a language doesn\'t exist', ->
    try
      T = new Translate('blah')
    catch e
      should.exist(e)

  describe 'each language', ->
    it 'should return the correct Riot locale', ->
      _.each riot_locales, (riot_locale, locale) ->
        T = new Translate(locale)
        T.riotLocale().should.equal(riot_locale)

    it 'should return the correct flag', ->
      _.each flags, (flag, locale) ->
        T = new Translate(locale)
        T.flag().should.equal(flag)
