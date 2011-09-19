require 'parslet'

class Edtf::Parser < Parslet::Parser
  rule(:int) { match('[0-9]') }
  rule(:zero_to_nine) { (str('0') >> match('[0-9]')) >> int.absnt? }
  rule(:one_to_nine) { (str('0') >> match('[1-9]')) >> int.absnt? }
  rule(:one_to_twelve) { (one_to_nine | str('10') | str('11') | str('12')) >> int.absnt? }
  rule(:zero_to_twenty_three) { (zero_to_nine | str('1') >> int | str('2') >> match('[0-3]')) >> int.absnt? }
  rule(:one_to_thirty_one) { (one_to_nine | match('[1-2]') >> int| str('30') | str('31')) >> int.absnt? }
  rule(:zero_to_fifty_nine) { (zero_to_nine | match('[1-5]') >> int) >> int.absnt? }
  rule(:four_digit_integer) { (int.repeat(4,4) | str('-') >> int.repeat(4)) >> int.absnt? }
  rule(:separator_dash) { str('-') }
  rule(:separator_time) { str('T') }
  rule(:separator_colon) { str(':') }
  rule(:separator_interval) { str('/') }
  rule(:separator) { }

  rule(:year) { four_digit_integer.as(:year) }
  rule(:month) { one_to_twelve.as(:month) }
  rule(:day) { one_to_thirty_one.as(:day) }

  rule(:year_month_day) { year >> separator_dash >> month >> separator_dash >> day }
  rule(:year_month) { year >> separator_dash >> month }
  rule(:month_day) { month >> separator_dash >> day }

  rule(:date) { 
    year_month_day |
    year_month |
    year
  }

  rule(:hours) { zero_to_twenty_three.as(:hours) }
  rule(:minutes) { zero_to_fifty_nine.as(:minutes) }
  rule(:seconds) { zero_to_fifty_nine.as(:seconds) }

  rule(:time) {
    hours >> separator_colon >> minutes >> separator_colon >> seconds
  }

  rule(:timezone_z) { str('Z') }
  rule(:timezone_offset) { (str('+') | str('-')) >> hours >> separator_colon >> minutes }
  rule(:timezone) { (timezone_z | timezone_offset).as(:timezone) }

  rule(:date_time) {
    date >> separator_t >> time >> timezone  |
    date >> separator_t >> time 
  }

  rule(:interval) {
     date.as(:interval_start) >> separator_interval >> date.as(:interval_end)
  }

  rule(:ind_uncertain) { str("?") }
  rule(:ind_approximate) { str("~") }

  rule(:uncertain_date) {
    date.as(:uncertain) >> ind_uncertain
  }

  rule(:approximate_date) {
    (uncertain_date).as(:approximate) >> ind_approximate |
    date.as(:approximate) >> ind_approximate
  }

  rule(:uncertain_or_approximate_date) { approximate_date | uncertain_date }

  rule(:ind_unspecified) { str('u') }
  rule(:ind_unknown) { str('unknown') }
  rule(:ind_open) { str('open') }

  rule(:underspecified_year) {
    (
      str("-").maybe >>
      int >> int >> (
        ind_unspecified >> ind_unspecified |
        int >> ind_unspecified
      )
    ).as(:unspecified).as(:year)
  }

  rule(:unspecified_year) { underspecified_year }

  rule(:unspecified_month) {
    ind_unspecified.repeat(2,2).as(:unspecified).as(:month)
  }

  rule(:unspecified_day) {
    ind_unspecified.repeat(2,2).as(:unspecified).as(:day)
  }

  rule(:unspecified_date) {
     underspecified_year |
     year >> separator_dash >> unspecified_month >> separator_dash >> unspecified_day |
     year >> separator_dash >> month >> separator_dash >> unspecified_day |
     year >> separator_dash >> unspecified_month 
  }

  rule(:extended_date) {
    uncertain_or_approximate_date | unspecified_date | date
  }

  rule(:extended_interval) {
    (extended_date | ind_unknown).as(:interval_start) >> separator_interval >> (extended_date | ind_unknown | ind_open).as(:interval_end)
  }

  rule(:ind_year) { str('y') }

  rule(:long_year) {
    ind_year >> int.repeat(4).as(:year) |
    ind_year >> (str('-') >> int.repeat(4)).as(:year)
  }

  rule(:season_spring) { str('21').as(:spring) }
  rule(:season_summer) { str('22').as(:summer) }
  rule(:season_autumn) { str('23').as(:autumn) }
  rule(:season_winter) { str('24').as(:winter) }
  rule(:season) { (season_spring | season_summer | season_autumn | season_winter).as(:season) }

  rule(:seasons) {
    year >> separator_dash >> season
  }

  rule(:edtf_level0) {
     date_time | interval | date
  }

  rule(:edtf_level1) {
     uncertain_or_approximate_date | unspecified_date | extended_interval | long_year | seasons
  }

  rule(:edtf) {
     edtf_level1  | edtf_level0
  }

  root :edtf
end
