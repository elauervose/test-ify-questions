# Parser for the files in the  test-categories directory which is capable of
# understanding the markdown and splitting it into POROs
module Graph
  class Parser
    ParseError = Class.new(StandardError)

    attr_accessor :errors

    Contract String => Any
    def initialize(filename)
      @filename = filename
      @errors = []
      @parsed = false
    end

    Contract nil => Question
    def parse!
      prompt = find_prompt_section!
      instructions, lettered, numbered = find_options_section!
      answers = find_answer_section!
      @parsed = true

      if valid?
        Question.new(prompt, instructions, lettered, numbered, answers)
      else
        fail ParseError
      end
    end

    Contract nil => Bool
    def valid?
      @parsed && errors.empty?
    end

    private

    attr_accessor :filename

    Contract nil => String
    def data
      @data ||= File.read(filename)
    end

    Contract nil => String
    def find_prompt_section!
      content = data.scan(/# Question([^#]*)/)[0][0]

      if content.empty?
        errors << 'Missing prompt'
        return ''
      else
        return content
      end
    end

    Contract nil => [String, Array, Array]
    def find_options_section!
      begin
        content = data.scan(/# Answer Options(.*)# Answer/m)[0][0].strip
        instructions = content.scan(/\s*> _([^_]*)_/)[0][0].strip
        lettered = content.scan(/\s*([a-z])\.\ (.*)/)
        numbered = content.scan(/\s*(\d)\.\ (.*)/)
      rescue
        errors << 'Missing options section'
        return ['', [], []]
      end

      if lettered.empty? || numbered.empty?
        errors << 'Missing options'
        return ['', [], []]
      else
        return [instructions, lettered, numbered]
      end
    end

    Contract nil => Array
    def find_answer_section!
      begin
        content = data.scan(/# Correct Answer(.*)/m)[0][0].strip
        answers = content.scan(/\*\ ([a-z])\.\ =\ (\d)/)
      rescue
        errors << 'Missing answers section'
        return []
      end

      if answers.empty?
        errors << 'Missing answers'
        return []
      else
        return answers
      end
    end
  end
end
