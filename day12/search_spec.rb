require './search'

RSpec.describe "Search" do
  subject { search arrangements, groups }

  context "with a single group" do
    context "of one bad spring" do
      let(:groups) { [1] }

      [
        ['empty string', '', 0],
        ['all "." string', '...', 0],
        ['specific', '#', 1],
        ['with leading/trailing "."', '..#..', 1],
        ['open', '?', 1],
        ['anchored', '?#?', 1],
      ].each do |variation, arrangements, expected_count|
        describe "when the arrangement is #{variation}" do
          let(:arrangements) { arrangements }
          it { is_expected.to eq expected_count }
        end
      end
    end

    context "of two bad spring" do
      let(:groups) { [2] }

      [
        ['two in four', '????', 3],
        ['two in four w/ anchor', '?#??', 2],
      ].each do |variation, arrangements, expected_count|
        describe "when the arrangement is #{variation}" do
          let(:arrangements) { arrangements }
          it { is_expected.to eq expected_count }
        end
      end
    end

    context "with mis-sized groups" do
      let(:arrangements) { ".#####." }

      [
        ['just right', 5, 1],
        ['too small', 4, 0],
        ['too large', 6, 0],
      ].each do |variation, group_size, expected_count|
        describe "when the group size is #{variation}" do
          let(:groups) { [group_size] }
          it { is_expected.to eq expected_count }
        end
      end
    end

    context "with folded records" do
      [
        ["???.###", [1, 1, 3], 1],
        [".??..??...?##.", [1, 1, 3], 4],
        ["?#?#?#?#?#?#?#?", [1, 3, 1, 6], 1],
        ["????.#...#...", [4, 1, 1], 1],
        ["????.######..#####.", [1, 6, 5], 4],
        ["?###????????", [3, 2, 1], 10],
      ].each do |arrangements, groups, expected_count|
        describe "when folded record is #{arrangements}, #{groups}" do
          let(:arrangements) { arrangements }
          let(:groups) { groups }
          it { is_expected.to eq expected_count }
        end
      end
    end

    context "with unfolded records" do
      [
        ["???.###", [1, 1, 3], 1],
        [".??..??...?##.", [1, 1, 3], 16_384],
        ["?#?#?#?#?#?#?#?", [1, 3, 1, 6], 1],
        ["????.#...#...", [4, 1, 1], 16],
        ["????.######..#####.", [1, 6, 5], 2_500],
        ["?###????????", [3, 2, 1], 506_250],
      ].each do |arrangements, groups, expected_count|
        describe "when unfolded record is #{arrangements}, #{groups}" do
          let(:arrangements) { Array.new(5, arrangements).join('?') }
          let(:groups) { Array.new(5, groups).flatten }
          it { is_expected.to eq expected_count }
        end
      end
    end

    context "work in progress samples" do
      [
        [".?.??..??...?##.", [1, 1, 3], 8],
        ["..??...?##.", [3], 1],
        ["?#???.#??#?????.?", [3, 1, 3, 1, 1], 12],
        ["?.?", [1], 2],
      ].each do |arrangements, groups, expected_count|
        describe "when unfolded record is #{arrangements}, #{groups}" do
          let(:arrangements) { arrangements }
          let(:groups) { groups }
          it { is_expected.to eq expected_count }
        end
      end
    end

    describe "long example" do
      let(:arrangements) { "?.#??#??.??????.???.#??#??.??????.???.#??#??.??????.???.#??#??.??????.???.#??#??.??????.?" }
      let(:groups) { [6, 1, 1, 1, 6, 1, 1, 1, 6, 1, 1, 1, 6, 1, 1, 1, 6, 1, 1, 1] }
      it { is_expected.to be > 0 }
    end
  end
end