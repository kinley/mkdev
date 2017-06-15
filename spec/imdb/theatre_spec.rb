require 'imdb/theatre'
require 'imdb/movie'

module IMDB
  describe Theatre do
    let(:theatre) { described_class.new('movies.txt', cash_amount) }
    let(:cash_amount) { 0 }

    describe '#initialize' do
      subject { theatre.all }

      it { is_expected.to have_attributes(count: 250) }
    end

    describe '#show' do
      before { allow(STDOUT).to receive(:puts) }
      subject { theatre.show(time) }

      context 'morning' do
        let(:time) { '8:00' }
        it { is_expected.to have_attributes(period: :ancient)}
      end

      context 'afternoon' do
        let(:time) { '12:00' }
        it { is_expected.to have_attributes(genres: include('Comedy'))
                        .or have_attributes(genres: include('Adventure')) }
      end

      context 'evening' do
        let(:time) { '18:00' }
        it { is_expected.to have_attributes(genres: include('Drama'))
                        .or have_attributes(genres: include('Horror')) }
      end

      context 'night' do
        let(:time) { '3:00' }
        it { is_expected.to be_nil}
      end
    end

    describe '#when?' do
      subject { theatre.when?(title) }

      context 'never' do
        let(:title) { 'The Terminator' }
        it { is_expected.to match_array([:never]) }
      end

      context 'morning' do
        let(:title) { 'M' }
        it { is_expected.to match_array([:morning, :evening]) }
      end

      context 'afternoon' do
        let(:title) { 'X-Men: Days of Future Past' }
        it { is_expected.to match_array([:afternoon]) }
      end

      context 'evening' do
        let(:title) { 'The Silence of the Lambs' }
        it { is_expected.to match_array([:evening]) }
      end
    end

    describe '#cash' do
      subject { theatre.cash }

      context 'no cash' do
        it { is_expected.to eq(0) }
      end

      context 'some cash' do
        let(:cash_amount) { 10 }
        it { is_expected.to eq(Money.from_amount(10)) }
      end

      context 'separate for each instance' do
        let(:cash_amount) { 20 }
        let(:another_theatre) { described_class.new('movies.txt', 5) }
        it { is_expected.to eq(Money.from_amount(20)) }
        it { expect(another_theatre.cash).to eq(Money.from_amount(5)) }
      end
    end

    describe '#buy_ticket' do
      subject { theatre.buy_ticket(day_period) }

      context 'morning' do
        let(:day_period) { :morning }
        let(:was) { Money.from_amount(0) }
        let(:become) { Money.from_amount(3) }
        it { expect { subject }.to change { theatre.cash }.from(was).to(become) }
              # .and_return('You bought ticket to ...') }
      end

      context 'afternoon' do
        let(:day_period) { :afternoon }
        let(:was) { Money.from_amount(0) }
        let(:become) { Money.from_amount(5) }
        it { expect { subject }.to change { theatre.cash }.from(was).to(become) }
      end

      context 'evening' do
        let(:day_period) { :evening }
        let(:was) { Money.from_amount(0) }
        let(:become) { Money.from_amount(10) }
        it { expect { subject }.to change { theatre.cash }.from(was).to(become) }
      end
    end

    describe '#take' do
      subject { theatre.take(who) }
      let(:cash_amount) { 10 }

      context 'Bank' do
        let(:who) { 'Bank' }
        let(:was) { Money.from_amount(10) }
        let(:become) { Money.from_amount(0) }
        it { expect { subject }.to change { theatre.cash }.from(was).to(become).and output("Проведена инкассация\n").to_stdout }
      end

      context 'someone else' do
        let(:who) { 'someone else' }
        it { expect { subject }.to raise_error(Cashbox::Unauthorized).and output("Полиция уже едет\n").to_stdout }
      end
    end
  end
end
