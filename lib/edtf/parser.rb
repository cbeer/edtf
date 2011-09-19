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

  rule(:simple_year) { four_digit_integer.as(:year) }
  rule(:simple_month) { one_to_twelve.as(:month) }
  rule(:simple_day) { one_to_thirty_one.as(:day) }

  rule(:year) { simple_year | unspecified_year | masked_year }
  rule(:month) { simple_month | unspecified_month }
  rule(:day) { simple_day | unspecified_day }

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
    date >> separator_time >> time >> timezone  |
    date >> separator_time >> time 
  }

  rule(:interval) {
     date.as(:interval_start) >> separator_interval >> date.as(:interval_end)
  }

  rule(:ind_uncertain) { str("?") }
  rule(:ind_approximate) { str("~") }

  rule(:uncertain_date) {
    date.as(:uncertain) >> ind_uncertain
  }

  rule(:approximate_year) { 
     year.as(:uncertain).as(:approximate) >> ind_uncertain >> ind_approximate |
     year.as(:approximate) >> ind_approximate |
     year.as(:uncertain) >> ind_uncertain
  }

  rule(:approximate_year_month) {
     year_month.as(:uncertain).as(:approximate) >> ind_uncertain >> ind_approximate |
     year_month.as(:approximate) >> ind_approximate |
     year_month.as(:uncertain) >> ind_uncertain
  }

  rule(:approximate_date) {
    (uncertain_date).as(:approximate) >> ind_approximate |
    date.as(:approximate) >> ind_approximate
  }

  rule(:partial_uncertain_or_approximate_date) {
    approximate_year >> separator_dash >> month_day |
    approximate_year_month >> separator_dash >> day |
    approximate_year_month |
    approximate_year
  }

  rule(:uncertain_or_approximate_date) { 
    partial_uncertain_or_approximate_date |
    approximate_date | 
    uncertain_date
  }

  rule(:ind_unspecified) { str('u') }
  rule(:ind_masked) { str('x') }
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

  rule(:masked_year) {
    (
      str("-").maybe >>
      int >> int >> (
        ind_masked >> ind_masked |
        int >> ind_masked
      )
    ).as(:masked).as(:year)
  }

  rule(:unspecified_year) { underspecified_year }

  rule(:unspecified_month) {
    ind_unspecified.repeat(2,2).as(:unspecified).as(:month)
  }

  rule(:unspecified_day) {
    ind_unspecified.repeat(2,2).as(:unspecified).as(:day)
  }

  rule(:unspecified_date) {
     (underspecified_year  |
     year >> separator_dash >> unspecified_month >> separator_dash >> unspecified_day |
     year >> separator_dash >> month >> separator_dash >> unspecified_day |
     year >> separator_dash >> unspecified_month) >> any.absnt? 
  }

  rule(:extended_date) {
    uncertain_or_approximate_date | unspecified_date | date
  }

  rule(:extended_interval) {
    (extended_date | ind_unknown).as(:interval_start) >> separator_interval >> (extended_date | ind_unknown | ind_open).as(:interval_end)
  }

  rule(:ind_year) { str('y') }

  rule(:long_year) {
    ind_year >> (int.repeat >> str("e") >> int.repeat(1) >> str('p') >> int.repeat(1)).as(:exponential_form).as(:year) |
    ind_year >> (str('-') >> int.repeat >> str("e") >> int.repeat(1) >> str('p') >> int.repeat(1)).as(:exponential_form).as(:year) |
    ind_year >> (int.repeat >> str("e") >> int.repeat).as(:exponential_form).as(:year) |
    ind_year >> (str('-') >> int.repeat >> str("e") >> int.repeat).as(:exponential_form).as(:year) |
    ind_year >> int.repeat(4).as(:year) |
    ind_year >> (str('-') >> int.repeat(4)).as(:year)
  }

  rule(:season_spring) { str('21').as(:spring) }
  rule(:season_summer) { str('22').as(:summer) }
  rule(:season_autumn) { str('23').as(:autumn) }
  rule(:season_winter) { str('24').as(:winter) }
  rule(:season) { (season_spring | season_summer | season_autumn | season_winter).as(:season) }

  rule(:season_qualifier) { str("^") >> any.repeat.as(:qualifier) }
  rule(:season_qualifier?) { season_qualifier.maybe }

  rule(:seasons) {
    year >> separator_dash >> season >> season_qualifier?
  }

  rule(:edtf_level0) {
     interval | date_time | date
  }

  rule(:edtf_level1) {
     extended_interval | uncertain_or_approximate_date | unspecified_date | long_year | seasons
  }

  rule(:edtf) {
     edtf_level1  | edtf_level0
  }

  root :edtf
end
