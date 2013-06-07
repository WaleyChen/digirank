# TODO:
# percentages to stars
# breaking ties of repetitions that have the same probabilities
# code algo s.t. the one with the longer repetition wins
class DigiRank
    PROBABILITY_OF_FIRST_DIGIT = 1
    PROBABILITY_OF_REPEATING_DIGIT = Rational(1, 10)
    PROBABILITY_OF_NON_REPEATING_DIGIT = Rational(9, 10)

    def self.unique_digit_count(number)
        unique_digit_hash = {}

        (0..(number.length - 1)).each do |index|
            unique_digit_hash[number[index]] = true if unique_digit_hash[number[index]].nil?
        end

        return unique_digit_hash.keys.count
    end

    def self.number_repetition_probability(number)
        repetition = number_to_repetition(number)
        probability = repetition_probability(repetition)

        # puts "#{ number } - #{ probability }"

        return probability
    end

    def self.repetition_probability(repetition)
        non_repeating_digits_count = 0
        repeating_digits_count = 0

        if !RepetitionProbability::REPETITION_PROBABILITY[repetition['length']].nil?
            return RepetitionProbability::REPETITION_PROBABILITY[repetition['length']][repetition.to_s]
        end

        repetition.keys.each do  |key|
            next if key == 'length'
            repeating_digits_count += key * repetition[key] - repetition[key]
        end
        non_repeating_digits_count = repetition['length'] - 1 - repeating_digits_count

        return PROBABILITY_OF_FIRST_DIGIT * 
                    (PROBABILITY_OF_REPEATING_DIGIT ** repeating_digits_count) * 
                    (PROBABILITY_OF_NON_REPEATING_DIGIT ** non_repeating_digits_count) * 
                    repetition_permutation_count(repetition)
    end

    def self.repetition_permutation_count(repetition)
        return 0 if repetition['length'] < 0
        return 1 if repetition['length'] == 0

        permutation_count = 0

        repetition.keys.each do |key|
            next if key == 'length'

            repetition_dup = repetition.dup
            repetition_dup['length'] -= key
            repetition_dup[key] -= 1
            repetition_dup.delete(key) if  repetition_dup[key] == 0

            permutation_count += repetition_permutation_count(repetition_dup)
        end

        return permutation_count
    end

    def self.number_to_repetition(number)
        accounted_for_last_digit = false
        repetition = {}
        sorted_repetition = {}
        repeat_count = 1;

        sorted_repetition['length'] = number.length

        (1..(number.length)).each do |index|
            if !accounted_for_last_digit  && index == number.length 
                add_repeat_count(repeat_count, repetition)
                break
            end

            if number[index] == number[index - 1]
                repeat_count += 1

                if index == number.length - 1
                    add_repeat_count(repeat_count, repetition)
                    accounted_for_last_digit = true
                    break
                end
            else
                add_repeat_count(repeat_count, repetition)
                repeat_count = 1
            end
        end

        repetition.keys.sort.each do |key|
            sorted_repetition[key] = repetition[key]
        end

        return sorted_repetition
    end

    def self.add_repeat_count(repeat_count, repetition)
        if repetition[repeat_count].nil?
            repetition[repeat_count] = 1
        else 
            repetition[repeat_count] += 1
        end
    end

    # slight modification of http://www.algorithmist.com/index.php/Coin_Change
    def self.generate_all_possible_repetitions(length)
        repetitions = []
        inner_generate_all_possible_repetitions(length, length, length, {}, repetitions)
        return repetitions
    end

    def self.inner_generate_all_possible_repetitions(length, repetition_length, original_length, repetition, repetitions)
        if length == 0
            repetition['length'] = original_length
            repetitions << Hash[repetition.to_a.reverse]
            return
        elsif length < 0
            return
        elsif repetition_length <= 0 && length > 0
            return
        end

        repetition_dup = repetition.dup
        repetition[repetition_length].nil? ? repetition[repetition_length] = 1 : repetition[repetition_length] += 1

        inner_generate_all_possible_repetitions(length, repetition_length - 1, original_length, repetition_dup, repetitions)
        inner_generate_all_possible_repetitions(length - repetition_length, repetition_length, original_length, repetition, repetitions)
    end
end