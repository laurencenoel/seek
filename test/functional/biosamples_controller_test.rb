require 'test_helper'

class BioSamplesControllerTest < ActionController::TestCase
  fixtures :all

  include AuthenticatedTestHelper

  def setup
    login_as(:aaron)
    @controller = BiosamplesController.new()
  end

  test 'should get the biosamples index page' do
    get :index
    assert_response :success
  end

  test 'should get the create_strain_popup' do
    get :create_strain_popup
    assert_response :success
    end

  test 'should get the create sample popup' do
    get :create_sample_popup
    assert_response :success
  end

  test 'should get strain form' do
    get :new_strain_form
    assert_response :success
  end

  test 'should not be able to go to the create_strain_popup without login' do
    @request.env["HTTP_REFERER"]  = ''
    logout
    get :create_strain_popup
    assert_not_nil flash[:error]
  end

  test 'should not be able to go to the create_sample_popup without login' do
    @request.env["HTTP_REFERER"]  = ''
    logout
    get :create_sample_popup
    assert_not_nil flash[:error]
  end

  test 'should show existing strains for selected organisms' do
    organism1 = organisms(:yeast)
    strains_of_organism1 = organism1.strains.reject { |s| s.is_dummy? }
    organism2 = organisms(:Saccharomyces_cerevisiae)
    strains_of_organism2 = organism2.strains.reject { |s| s.is_dummy? }
    #organism3 doesn't have any strains
    organism3 = organisms(:human)
    strains_of_organism3 = organism3.strains.reject { |s| s.is_dummy? }

    strains = strains_of_organism1 + strains_of_organism2 + strains_of_organism3

    organism_ids = organism1.id.to_s + ',' + organism2.id.to_s  + ',' + organism3.to_s
    get :existing_strains, :organism_ids => organism_ids
    assert_response :success
    assert_select "table#strain_table tbody" do
      assert_select 'tr td a[href=?]', organism_path(organism1.id), :count => strains_of_organism1.length
      assert_select 'tr td a[href=?]', organism_path(organism2.id), :count => strains_of_organism2.length
      assert_select 'tr td a[href=?]', organism_path(organism3.id), :count => strains_of_organism3.length
      strains.each do |strain|
        assert_select 'tr td', :text => strain.id, :count => 1
      end
    end
  end

  test "should show existing specimens for selected strains" do
    strain1 = strains(:yeast1)
    specimens_of_strain1 = strain1.specimens.select(&:can_view?)
    strain2 = strains(:yeast2)
    specimens_of_strain2 = strain2.specimens.select(&:can_view?)
    #strain3 doesn't have any specimens
    strain3 = strains(:Saccharomyces_cerevisiae1)
    specimens_of_strain3 = strain3.specimens.select(&:can_view?)
    specimens = specimens_of_strain1 + specimens_of_strain2 + specimens_of_strain3

    strain_ids = strain1.id.to_s + ',' + strain2.id.to_s + ',' + strain3.id.to_s
    get :existing_specimens, :strain_ids => strain_ids
    assert_response :success
    assert_select "table#specimen_table tbody" do
      assert_select 'tr td', :text => "Strain " + strain1.info + "(ID=#{strain1.id})", :count => specimens_of_strain1.length
      assert_select 'tr td', :text => "Strain " + strain2.info + "(ID=#{strain2.id})", :count => specimens_of_strain2.length
      assert_select 'tr td', :text => "Strain " + strain3.info + "(ID=#{strain3.id})", :count => specimens_of_strain3.length
      specimens.each do |specimen|
        assert_select 'tr td', :text => specimen.id, :count => 1
      end
    end
  end

  test "should show existing samples for selected specimens" do
    specimen1 = specimens("running mouse")
    samples_of_specimen1 = specimen1.samples.select(&:can_view?)
    specimen2 = specimens("running mouse2")
    samples_of_specimen2 = specimen2.samples.select(&:can_view?)

    samples = samples_of_specimen1 + samples_of_specimen2

    specimen_ids = specimen1.id.to_s + ',' + specimen2.id.to_s
    get :existing_samples, :specimen_ids => specimen_ids
    assert_response :success
    assert_select "table#sample_table tbody" do
      assert_select 'tr td', :text => CELL_CULTURE_OR_SPECIMEN.capitalize + ' ' + specimen1.title, :count => samples_of_specimen1.length
      assert_select 'tr td', :text => CELL_CULTURE_OR_SPECIMEN.capitalize + ' ' + specimen2.title, :count => samples_of_specimen2.length
      samples.each do |sample|
        assert_select 'tr td', :text => sample.id, :count => 1
      end
    end
  end

end
