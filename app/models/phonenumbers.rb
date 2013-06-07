require "digirank"
require "float"
require 'money'

class Phonenumbers
    include Mongoid::Document

    field :price

    field :phonenumber
    field :phonenumber_html
    field :phonenumber_repetition_html
    field :phonenumber_unique_digit_html
    field :phonenumber_both_html

    field :iso_country
    field :region
    field :location

    field :repetition_percentage
    field :repetition_probability, type: Float
    field :repetition_probability_numerator
    field :repetition_probability_denominator
    field :unique_digit_count

    validates_uniqueness_of :phonenumber

    index({ repetition_probability: 1 }, {name: "repetition_probability_index"})
    index({ unique_digit_count: 1 }, {name: "unique_digit_count_index"})
    index({ unique_digit_count: 1, repetition_probability: 1 }, {name: "both"})

    COLOURS = ['#333333', '#FF9900', '#669966', '#993366', '06A2CB', '#8F6048', '#FD795B', '397249', '#C00', '#666666']

    def set_price
        self.price = ((self.phonenumber.length - self.unique_digit_count) + 0.5/repetition_probability)
        puts self.price
        puts Money.new(self.price * 100, "USD")
        self.price = Money.new(self.price * 100, "USD").format(:symbol => false)
        self.save
    end

    def set_repetition_percentage
        # puts self.repetition_probability

        start_counting = false
        significant_digit_count = 0
        significant_digits =  (self.repetition_probability * 100) .signif(3).to_s
        puts significant_digits
        repetition_percentage = ''

        # puts significant_digits

        (0..significant_digits.length - 1).each do |index|
            break if significant_digit_count == 3
            repetition_percentage = "#{repetition_percentage}#{significant_digits[index]}"
            # puts repetition_percentage
            next if significant_digits[index] == '.'
            next if (significant_digits[index] == '0' || significant_digits[index] == '.' ) && start_counting == false
            start_counting = true
            significant_digit_count += 1
        end

         puts repetition_percentage

        # puts repetition_percentage
        repetition_percentage = "#{ repetition_percentage }%"

        self.repetition_percentage = repetition_percentage
        self.save
    end

    def set_both_html
        colour = 0
        self.phonenumber_both_html = ''

        (0..self.phonenumber.length - 1).each do |num|
            font_weight = 'normal'

            if num > 1 && phonenumber[num] != phonenumber[num - 1]
            elsif num > 1 && phonenumber[num] == phonenumber[num - 1]
                font_weight = 'bold'
            end

            if num != phonenumber.length - 1 && phonenumber[num] == phonenumber[num + 1]
                font_weight = 'bold'
            end

            colour = COLOURS[phonenumber[num].to_i]
            self.phonenumber_both_html += "<div style=\"display: inline-block; color: #{ colour }; font-weight: #{ font_weight }; font-size: 18px;\"> #{ self.phonenumber[num] } </div>"
        end

        puts self.phonenumber_both_html
        puts self.save
    end

    def set_unique_digit_html
        colour = 0
        self.phonenumber_unique_digit_html = ''

        (0..self.phonenumber.length - 1).each do |num|
            font_weight = 'normal'

            # if num > 1 && phonenumber[num] != phonenumber[num - 1]
            #     colour += 1 
            #     colour %= COLOURS.count
            # else
            #     # font_weight = 'bold'
            # end

            # if num != phonenumber.length - 1 && phonenumber[num] == phonenumber[num + 1]
            #     # font_weight = 'bold'
            # end
            colour = COLOURS[phonenumber[num].to_i]
            self.phonenumber_unique_digit_html += "<div style=\"display: inline-block; color: #{ colour }; font-weight: #{ font_weight }; font-size: 18px;\"> #{ self.phonenumber[num] } </div>"
        end

        puts self.phonenumber_unique_digit_html
        puts self.save
    end

    def set_phonenumber_repetition_html
        self.phonenumber_repetition_html = ''

        (0..self.phonenumber.length - 1).each do |num|
            font_weight = 'normal'

            if num > 1 && phonenumber[num] != phonenumber[num - 1]
            elsif num > 1 && phonenumber[num] == phonenumber[num - 1]
                font_weight = 'bold'
            end

            if num != phonenumber.length - 1 && phonenumber[num] == phonenumber[num + 1]
                font_weight = 'bold'
            end

            self.phonenumber_repetition_html += "<div style=\"display: inline-block; font-weight: #{ font_weight }; font-size: 18px;\"> #{ self.phonenumber[num] } </div>"
        end

        puts self.phonenumber_repetition_html
        puts self.save
    end

    def set_phonenumber_html
        colour = 0
        self.phonenumber_html = ''

        (0..self.phonenumber.length - 1).each do |num|
            font_weight = 'normal'

            if num > 1 && phonenumber[num] != phonenumber[num - 1]
                colour += 1 
                colour %= 2
            else
                font_weight = 'bold'
            end

            if num != phonenumber.length - 1 && phonenumber[num] == phonenumber[num + 1]
                font_weight = 'bold'
            end

            self.phonenumber_html += "<div style=\"display: inline-block; color: #{ COLOURS[colour] }; font-weight: #{ font_weight }; font-size: 18px;\"> #{ self.phonenumber[num] } </div>"
        end

        puts self.phonenumber_html
        puts self.save
    end

    def set_location
        if self.iso_country.nil? && self.region.nil?
            self.location = ''
        elsif self.iso_country.present? && self.region.nil?
            self.location = iso_country
        elsif self.iso_country.nil? && self.region.present?
            self.location = self.region
        else
            self.location = "#{ iso_country }, #{ self.region }"
        end

        puts self.save
    end

    def set_repetition_probability
        pn = phonenumber.slice(1..phonenumber.length - 1)
        repetition_probability = DigiRank::number_repetition_probability(pn)
        self.repetition_probability_numerator = repetition_probability.numerator
        self.repetition_probability_denominator = repetition_probability.denominator
        self.repetition_probability = repetition_probability.numerator.to_f/repetition_probability.denominator
        puts self.repetition_probability
        puts self.save
    end

    def set_unique_digit_count
        pn = phonenumber.slice(1..phonenumber.length - 1)
        self.unique_digit_count = DigiRank::unique_digit_count(pn)
        self.save
    end
end