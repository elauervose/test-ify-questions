require_relative 'spec_helper'
require_relative '../lib/graph'

describe Graph::Parser do
  context 'the happy path' do
    subject { Graph::Parser.new(File.expand_path('./spec/fixtures/questions/1234-matcher.md')) }

    it 'takes a filename' do
      expect(subject.instance_variable_get(:@filename)).to match('/fixtures/questions/1234-matcher.md')
    end

    it 'parses the file into a Question object' do
      question = subject.parse!
      expect(question).to be_a Question
      expect(subject.valid?).to be true
    end
  end

  context 'with a massively wrong file' do
    it 'raises hell if a path is not found' do
      expect { Graph::Parser.new('snatoheusnht').parse! }.to raise_error(Errno::ENOENT)
    end

    it 'complains if the file is missing sections' do
      subject = Graph::Parser.new(File.expand_path('./spec/fixtures/questions/1234-missing-content.md'))
      expect { subject.parse! }.to raise_error(Graph::Parser::ParseError)
      expect(subject.valid?).to be false
      expect(subject.errors).to eq([
        'Missing options section',
        'Missing answers'
      ])
    end
  end

  context 'with a slightly malformed file' do
    subject { Graph::Parser.new(File.expand_path('./spec/fixtures/questions/1234-broken.md')) }

    it 'shows that the file is invalid' do
      expect(subject.valid?).to be false
    end

    it 'complains about various errors' do
      expect(subject.errors)
    end
  end
end
