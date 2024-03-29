require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'parslet/rig/rspec'

describe Edtf::Parser do
  let(:parser) { Edtf::Parser.new }

  context "basic atoms" do
    context "year" do
      it "should only consume 4 digit years" do
        parser.year.should_not parse("1")
        parser.year.should_not parse("12")
        parser.year.should_not parse("123")
        parser.year.should parse("2008")
        parser.year.should parse("-0999")
        parser.year.should parse("0000")
        parser.year.should_not parse("12345")
        parser.year.should_not parse("123456")
      end
    end

    context "month" do
      it "should parse 01 - 12" do
        parser.month.should_not parse("00")
        parser.month.should parse("01")
        parser.month.should parse("09")
        parser.month.should parse("12")
        parser.month.should_not parse("13")
      end
    end

    context "day" do
      it "should parse 01 - 31" do
        parser.day.should_not parse("00")
        parser.day.should parse("01")
        parser.day.should parse("25")
        parser.day.should_not parse("32")
        parser.day.should_not parse("40")
      end
    end         

    context "hours" do
      it "should consume 00 - 23" do
        parser.hours.should parse('00')
        parser.hours.should parse('20')
        parser.hours.should parse('23')
        parser.hours.should_not parse('24')
      end
    end

    context "minutes" do
      it "should consume 00 - 59" do
        parser.minutes.should parse('00')
        parser.minutes.should parse('59')
        parser.minutes.should_not parse('60')
      end
    end

    context "seconds" do
      it "should consume 00 - 59" do
        parser.seconds.should parse('00')
        parser.seconds.should parse('59')
        parser.seconds.should_not parse('60')
      end
    end

    context "timezone" do
      it "should consume Z" do
        parser.timezone.should parse("Z")
      end

      it "should consume offsets" do
        parser.timezone.should parse("+00:00")
        parser.timezone.should parse("+05:00")
        parser.timezone.should parse("-11:45")
      end
    end
  end

  context "001 Date: ISO 8601 extended form" do
 

    it "should consume year,month,date" do
      parser.should parse('2001-02-03')
    end

    it "should consume year, month" do
      parser.should parse('2008-12')
    end

    it "should consume year" do
      parser.should parse("1998")
    end
  end

  context "002 Date and Time: ISO 8601 extended form" do
    it "should consume ymdthms" do
      parser.should parse("2001-02-03T09:30:01")
    end

    it "should consume ymdthmsz" do
      parser.should parse("2004-01-01T10:10:10Z")
    end

    it "should consume ymdthms+-" do
      parser.should parse("2004-01-01T10:10:10+05:00")
    end
  end

  context "003 Interval (start/end)" do
    it "should consume year precision" do
      parser.should parse("1964/2008")
    end

    it "should consume year, month precision" do
      parser.should parse("2004-06/2006-08")
    end

    it "should consume year,month.day precision" do
      parser.should parse("2004-02-01/2005-02-08")
    end

    it "should consume interval endpoints with differing precision" do
      parser.should parse("2004-02-01/2005-02")
      parser.should parse("2004-02-01/2005")
      parser.should parse("2005/2006-02")
    end
  end

  context "101 Uncertain/Approximate" do
    it "should consume uncertain year" do
      parser.should parse("1984?")
    end

    it "should consume uncertain year, month" do
      parser.should parse("2004-06?")
    end

    it "should consume uncertain year, month, day" do
      parser.should parse("2004-06-11?")
    end

    it "should consume approximate year" do
      parser.should parse("1984~")
    end

    it "should consume an approximate and uncertain year" do
      parser.should parse("1984?~")
    end
  end

  context "102 Unspecified" do
    it "should consume underspecified years" do
      parser.should parse("199u")
      parser.should parse("19uu")
    end

    it "should consume unspecified months" do
      parser.should parse("1999-uu")
    end

    it "should consume unspecified days" do
      parser.should parse("1999-01-uu")
    end                                    

    it "should consume unspecified month, day" do
      parser.should parse("1999-uu-uu")
    end
  end

  context "103 L1 Extended Interval" do
    it "should consume beginning unknown, end year" do
      parser.should parse("unknown/2006")
    end

    it "should consume begnning, end unknown" do
      parser.should parse("2004-06-01/unknown")
    end

    it "should consume beginning, end open" do
      parser.should parse("2004-01-01/open")
    end

    it "should consume approximate beginning, end year,month" do
      parser.should parse("1984~/2004-06")
    end

    it "should consume beginning year, end approximate" do
      parser.should parse("1984/2004-06~")
    end

    it "should consume approximate beginning and end" do
      parser.should parse("1984~/2004~")
    end

    it "should consume uncertain beginning, approximate and uncertain end" do
      parser.should parse("1984?/2004?~")
    end

    it "should consume uncertain beginning and end" do
      parser.should parse("1984-06?/2004-08?")
    end

    it "should consume uncertain beginning, approximate end" do
      parser.should parse("1984-06-02?/2004-08-08~")
    end

    it "should consume uncertain beginning, unknown end" do
      parser.should parse("1984-06-02?/unknown")
    end
  end

  context "104 Year exceeding four digits" do
    it "should consume y170000002" do
      parser.should parse("y1700000002")
    end

    it "should consume y-170000002" do
      parser.should parse("y-1700000002")
    end
  end

  context "105 Season" do
    it "should consume all seasons" do
      parser.should parse('2001-21')
    end
  end

  context "201 Partial Uncertain" do
    it "should consume uncertain year; month day known" do
      parser.should parse("2004?-06-11")
    end

    it "should consume approxumate year and month; day known" do
      parser.should parse("2004-06~-11")
    end
  end

  context "202 Partial Unspecified" do
    it "should" do
      parser.should parse("156u-12-25")
    end

    it "should" do
      parser.should parse("15uu-12-25")
    end

    it "should" do
      parser.should parse('15uu-12-uu')
    end

    it "should" do
      parser.should parse("1560-uu-25")
    end
  end

  context "205 Masked Precision" do
    it "should" do
      parser.should parse("196x")
    end

    it "should" do
      parser.should parse("19xx")
    end
  end

  context "208 Year Requiring More than Four Digits" do
    it "should" do
      parser.should parse("y17e7")
    end

    it "should" do
      parser.should parse("y-17e7")
    end

    it "should" do
      parser.should parse("y17101e4p3")
    end
  end

  context "209 Season - Qualified" do
    it "should" do
      parser.should parse("2001-21^southernHemisphere")
    end
  end
end
