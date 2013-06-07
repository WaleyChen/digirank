# TODO
# generate all possisble repetitions and they should add to 100%

require "./digirank"
require "test/unit"
 
class DigirankTest < Test::Unit::TestCase
    # ---------------------------------------- unique_digit_count tests --------------------------------------------------
    UNIQUE_DIGIT_COUNT_PROVIDER = {
        '1111111111' => 1,
        '1212121212' => 2,
        '1231231231' => 3,
        '1234567890' => 10
    }

    def test_unique_digit_count
        UNIQUE_DIGIT_COUNT_PROVIDER.keys.each do |key|
            assert_equal(UNIQUE_DIGIT_COUNT_PROVIDER[key], DigiRank::unique_digit_count(key))
        end
    end

    # ---------------------------------------- repetition_probability tests ------------------------------------------------
    REPETITION_PROBABILITY_PROVIDER = {
        1 => [
            1
        ],
        2 => [
            Rational(9, 10), 
            Rational(1, 10)
        ],
        3 => [
            Rational(9**2, 10**2), 
            Rational(9 * 2, 10**2), 
            Rational(1, 10**2)
        ],
        4 => [
            Rational(9**3, 10**3), 
            Rational(9**2 * 3, 10**3), 
            Rational(9, 10**3),
            Rational(9 * 2, 10**3), 
            Rational(1, 10**3)
        ],
        5 => [
            Rational(9**4, 10**4),
            Rational(9**3 * 4, 10**4),
            Rational(9**2 * 3, 10**4),
            Rational(9**2 * 3, 10**4),
            Rational(9 * 2, 10**4),
            Rational(9 * 2, 10**4),
            Rational(1, 10**4)
        ],
        6 => [
            Rational(9**5, 10**5),
            Rational(9**4 * 5, 10**5),
            Rational(9**3 * 6, 10**5),
            Rational(9**2, 10**5),
            Rational(9**3 * 4, 10**5),
            Rational(9**2 * 6, 10**5),
            Rational(9, 10**5),
            Rational(9**2 * 3, 10**5),
            Rational(9 * 2, 10**5),
            Rational(9 * 2, 10**5),
            Rational(1, 10**5)
        ]
    }

    def test_repetition_probabilitys
        REPETITION_PROBABILITY_PROVIDER.keys.each do |key|
            repetition_probabilities = 0
            expected_repetition_probability = REPETITION_PROBABILITY_PROVIDER[key]
            repetitions = DigiRank::generate_all_possible_repetitions(key)

            repetitions.each_with_index do |repetition, index|
                repetition_probability = DigiRank::repetition_probability(repetition)
                assert_equal(expected_repetition_probability[index], repetition_probability, "key: #{ key } index: #{ index }")
                repetition_probabilities += repetition_probability
            end

            assert_equal(1, repetition_probabilities)
        end
    end

    def test_repetition_probability_of_length_6_to_10
        (6..10).each do |index|
            repetition_probabilitys = 0
            repetitions = DigiRank::generate_all_possible_repetitions(index)

            repetitions.each_with_index do |repetition, index|
                repetition_probabilitys += DigiRank::repetition_probability(repetition)
            end

            assert_equal(1, repetition_probabilitys)
        end
    end

    # ---------------------------------------- repetition_permutation_count tests -------------------------------------------
    REPETITION_PERMUTATION_COUNT_PROVIDER = {
        1 => [1],
        2 => [1, 1],
        3 => [1, 2, 1],
        4 => [1, 3, 1, 2, 1],
        5 => [1, 4, 3, 3, 2, 2, 1],
        6 => [1, 5, 6, 1, 4, 6, 1, 3, 2, 2, 1]
    }

    def test_permuations_count
        REPETITION_PERMUTATION_COUNT_PROVIDER.keys.each do |key|
            expected_permutations_counts = REPETITION_PERMUTATION_COUNT_PROVIDER[key]
            repetitions = DigiRank::generate_all_possible_repetitions(key)

            repetitions.each_with_index do |repetition, index|
                assert_equal(expected_permutations_counts[index], DigiRank::repetition_permutation_count(repetition), "key: #{ key } index: #{ index }")
            end
        end
    end

    # ---------------------------------------- generate_all_possible_repetitions tests ----------------------------------------
    GENERATE_ALL_POSSIBLE_REPETITIONS_PROVIDER = {
        1 => [
            { 'length' => 1, 1 => 1 }
        ],
        2 => [
            { 'length' => 2, 1 => 2 },
            { 'length' => 2, 2 => 1 }
        ] ,
        3 => [
            { 'length' => 3, 1 => 3 },
            { 'length' => 3, 1 => 1, 2 => 1 },
            { 'length' => 3, 3 => 1 }
        ],
        4 => [
            { 'length' => 4, 1 => 4 },
            { 'length' => 4, 1 => 2, 2 => 1 },
            { 'length' => 4, 2 => 2 },
            { 'length' => 4, 1 => 1, 3=> 1 },
            { 'length' => 4, 4 => 1 }
        ],
        5 => [
            { 'length' => 5, 1 => 5 },
            { 'length' => 5, 1 => 3, 2 => 1 },
            { 'length' => 5, 1 => 1, 2 => 2 },
            { 'length' => 5, 1 => 2, 3 => 1 },
            { 'length' => 5, 1 => 1, 4 => 1 },
            { 'length' => 5, 2 => 1, 3 => 1 },
            { 'length' => 5, 5 => 1 }
        ],
        6 => [
            { 'length' => 6, 1 => 6 },
            { 'length' => 6, 1 => 4, 2 => 1 },
            { 'length' => 6, 1 => 2, 2 => 2 },
            { 'length' => 6, 2 => 3 },
            { 'length' => 6, 1 => 3, 3 => 1 },
            { 'length' => 6, 1 => 1, 2 => 1, 3 => 1 },
            { 'length' => 6, 3 => 2 },
            { 'length' => 6, 1 => 2, 4 => 1 },
            { 'length' => 6, 2 => 1, 4 => 1 },
            { 'length' => 6, 1 => 1, 5 => 1 },
            { 'length' => 6, 6 => 1 }
        ]
    }

    def test_generate_all_possible_repetitions
        GENERATE_ALL_POSSIBLE_REPETITIONS_PROVIDER.keys.each do |key|
            repetitions = DigiRank::generate_all_possible_repetitions(key)

            GENERATE_ALL_POSSIBLE_REPETITIONS_PROVIDER[key].each do |expected_repetition|
                assert(repetitions.include?(expected_repetition))
            end

            assert_equal(repetitions.count, GENERATE_ALL_POSSIBLE_REPETITIONS_PROVIDER[key].count, "key: #{ key }")
        end
    end
    # ---------------------------------------- number_to_repetition tests -------------------------------------------------
    NUMBER_TO_REPETITION_PROVIDER = {
        '1111111111' => { 'length' => 10, 10 => 1 },
        '0129202087' => { 'length' => 10, 1 => 10 },
        '1112234444' => { 'length' => 10, 1 => 1, 2 => 1, 3 => 1, 4 => 1 },
        '12345' => { 'length' => 5, 1 => 5},
        '12233' => { 'length' => 5, 1 => 1, 2 => 2},
        '22115' => { 'length' => 5, 1 => 1, 2 => 2}
    }

    def test_number_to_repetition
        NUMBER_TO_REPETITION_PROVIDER.keys.each do |key|
            assert_equal(NUMBER_TO_REPETITION_PROVIDER[key], DigiRank::number_to_repetition(key))
        end
    end
end