require 'rails_helper'

describe Assessment::GradingsController do

  def should_not_match(answer, keyword)
    expect(answer.match(subject.send(:keyword_regex, keyword))).to be_falsey
  end

  def match(answer, keyword)
    expect(answer.match(subject.send(:keyword_regex, keyword))).to be_truthy
  end

  def match_commutative(answer, keyword)
    match answer, keyword
    match keyword, answer
  end

  it 'should match trivial cases' do
    match 'abc', 'abc'
    match 'This is a test.', 'This is a test.'
  end

  it 'should match between word boundaries' do
    should_not_match 'abc def something else', 'def some'
    should_not_match 'abc def something else', 'ef some'
    should_not_match 'abc def something else', 'some'
    should_not_match 'abc def something else', 'b'
  end

  it 'should match multiple words' do
    match 'abc def', 'abc def'
    match 'abc def something else', 'def something'
  end

  it 'should match despite punctuation' do
    match_commutative 'abc', 'abc.'
    match_commutative 'abc.', '.abc'
    match 'abc', 'a!!bc'
  end

  it 'should match despite case' do
    match 'Abc', 'Abc'
    match_commutative 'abc', 'Abc'
    match_commutative 'Abc', 'ABC'
    match_commutative 'abc', 'ABC'
  end

  it 'should match keywords given as singular' do
    match 'people', 'person'
    match 'dresses', 'dress'
    match 'minerals', 'mineral'
  end

  it 'should match keywords given as plural' do
    match 'people', 'people'
    match 'person', 'people'
    match 'person', 'persons'
    match 'dress', 'dresses'
    match 'dresses', 'dress'
    match 'mineral', 'minerals'

    # Pathological cases

    # Will fail:
    # match 'people', 'persons'
    # match 'persons', 'person'

    # Will pass:
    match 'dres', 'dress'
  end

  it 'should match sentence fragments' do
    match 'This is a test.', 'test'
    match 'This is a test.', 'this'
    match 'This is a test.', 'is a'
  end
end
