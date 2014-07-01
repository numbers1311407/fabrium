require 'test_helper'

class FabricVariantTest < ActiveSupport::TestCase
  test '"#" #color prefix is stripped' do
    f = FabricVariant.new(color: '#ff0000')
    assert_equal 'ff0000', f.color
  end

  test "#color is downcased" do
    f = FabricVariant.new(color: '#FF0000')
    assert_equal 'ff0000', f.color
  end

  test "#color.to_lab should equal #lab" do
    f = FabricVariant.new
    assert_decimal_arrays_equal f.lab, f.color.to_lab

    f.color = "ff0000"
    assert_decimal_arrays_equal f.lab, f.color.to_lab

    f.color = "0dfa3c"
    assert_decimal_arrays_equal f.lab, f.color.to_lab
  end

  test "#color.to_lab for nil color should be [0, 0, 0]" do
    f = FabricVariant.new
    assert_decimal_arrays_equal [0, 0, 0], f.color.to_lab
  end

  test "#color.to_xyz for nil color should be [0, 0, 0]" do
    f = FabricVariant.new
    assert_decimal_arrays_equal [0, 0, 0], f.color.to_xyz
  end


  # Test a simple color

  test "ff0000 to rgb" do
    f = FabricVariant.new(color: "ff0000")
    assert_decimal_arrays_equal [255, 0, 0], f.color.to_rgb
  end

  test "ff0000 to xyz" do
    f = FabricVariant.new(color: "ff0000")
    assert_decimal_arrays_equal [41.24, 21.26, 1.93], f.color.to_xyz
  end

  test "ff0000 to lab" do
    f = FabricVariant.new(color: "ff0000")
    assert_decimal_arrays_equal [53.23, 80.11, 67.22], f.color.to_lab
  end


  # Test an arbitrary color

  test "df20be to rgb" do
    f = FabricVariant.new(color: "df20be")
    assert_decimal_arrays_equal [223, 32, 190], f.color.to_rgb
  end

  test "df20be to xyz" do
    f = FabricVariant.new(color: "df20be")
    assert_decimal_arrays_equal [40.24, 20.44, 50.54], f.color.to_xyz
  end

  test "df20be to lab" do
    f = FabricVariant.new(color: "df20be")
    assert_decimal_arrays_equal [52.33, 80.92, -37.04], f.color.to_lab
  end

  private

  def assert_decimal_arrays_equal(expected, got, precision=2)
    strf = "%.#{precision}f"

    expected.zip(got) do |t|
      if (strf % t[0]) != (strf % t[1])
        assert false, "expected: #{expected}, got: #{got}"
        return
      end
    end

    assert true
  end

end
