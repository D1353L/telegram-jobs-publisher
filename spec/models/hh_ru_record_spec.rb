# frozen_string_literal: true

describe HhRuRecord do
  subject do
    described_class.new(title: 'Anything', company_name: 'Company')
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a title' do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a company_name' do
    subject.company_name = nil
    expect(subject).to_not be_valid
  end
end
