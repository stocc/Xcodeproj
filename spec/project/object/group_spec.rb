require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXGroup" do
    before do
      @group = @project.new_group('Parent')
      @group.new_file('Abracadabra.h')
      @group.new_file('Banana.h')
      @group.new_group('ZappMachine')
      @group.new_file('Abracadabra.m')
      @group.new_file('Banana.m')
    end

    it "is removed from the original group when added to another group" do
      new_group = @project.new_group('New Group')
      new_group.children << @group
      new_group.children.should.include @group
      @group.referrers.should.include new_group
      @project.main_group.children.should.not.include @group
    end

    it "sorts by group vs file first, then name" do
      @group.new_group('Apemachine')
      @group.sort_by_type.map(&:name).should == %w{
        Apemachine ZappMachine
        Abracadabra.h Abracadabra.m Banana.h Banana.m
      }
    end

    it "creates nested groups" do
      @project.new_group('groups', 'some/dir/and/sub/groups')
      
      groups = @project.main_group.groups
      %w{some dir and sub groups}.each do |group_name|
        group = groups.select { |g| g.name == group_name }.first
        group.should != nil
        groups = group.groups
      end
      
    end

    it "returns that the main group has no name" do
      @project.main_group.name.should == nil
    end

    it "returns its name" do
      @group.name.should == 'Parent'
    end

    it "adds files for the given paths" do
      file = @group.new_file('ZOMG.md')
      file.path.should == 'ZOMG.md'
      @group.files.should.include file
    end

    it "returns a list of files and groups" do
      @group.children.map(&:name).sort.should == %w{ Abracadabra.h Abracadabra.m Banana.h Banana.m ZappMachine }
    end

    it "adds XCVersionGroups" do
      group = @group.new_xcdatamodel_group('some/Model.xcdatamodeld')
      group.isa.should == 'XCVersionGroup'
      group.source_tree.should == '<group>'
      group.version_group_type.should == 'wrapper.xcdatamodel';
    end
  end
end

