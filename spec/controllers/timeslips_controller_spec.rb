require 'spec_helper'

describe TimeslipsController do
  
  context :index do
    before(:each) do
      @company = Factory.create(:company)
      @user = Factory.create(:user, :company => @company, :owns_company => true)
      @sub_user = Factory.create(:user, :company => @company, :sub_account => true, :email => "subaccount@example.com")
      @project = Factory.create(:project, :company => @company)
      @sub_timeslip = Factory.create(:timeslip, :project => @project, :user => @sub_user)
      @user_timeslip = Factory.create(:timeslip, :project => @project, :user => @user)
    end

    describe "company owner" do
      it "should show the current timeslips for the company" do
        sign_in @user
        get :index
        assigns[:timeslips].count.should == 2
        sign_out @user
      end
    end

    describe "company sub account" do
      it "should show the current timeslips for the user" do
        sign_in @sub_user
        get :index
        assigns[:timeslips].count.should == 1
        sign_out @sub_user
      end
    end
  end

  context :new do
    before(:each) do
      @company = Factory.create(:company)
      @user = Factory.create(:user, :company => @company, :owns_company => true)
      @sub_user = Factory.create(:user, :company => @company, :sub_account => true, :email => "subaccount@example.com")
      @project = Factory.create(:project, :company => @company)
      @sub_timeslip = Factory.create(:timeslip, :project => @project, :user => @sub_user)
      @user_timeslip = Factory.create(:timeslip, :project => @project, :user => @user)
    end

    describe "project manager" do
      before(:each) do
        sign_in @user
        post :new
      end

      after(:each) do
        sign_out @user
      end

      it "should create a new task" do
        response.should be_success
      end

      it "should get the current tasks" do
        task = Factory.create(:task, :project_id => @project.id, :name => 'task name')
        assigns[:tasks].count.should == 1
      end

      it "should get the current projects" do
        assigns[:projects].count.should == 1
      end

      it "should get the current users" do
        assigns[:users].count.should == 2
      end
    end

    describe "project sub account" do
      before(:each) do
        sign_in @sub_user
        post :new
      end

      after(:each) do
        sign_out @sub_user
      end

      it "should create a new task" do
        response.should be_success
      end

      it "should get the current tasks" do
        task = Factory.create(:task, :project_id => @project.id, :name => 'task name')
        assigns[:tasks].count.should == 1
      end

      it "should get the current projects" do
        assigns[:projects].count.should == 1
      end

      it "should get the current users" do
        assigns[:users].count.should == 1
      end
    end
  end

  context :create do
    before(:each) do
      @company = Factory.create(:company)
      @user = Factory.create(:user, :company => @company, :owns_company => true)
      @sub_user = Factory.create(:user, :company => @company, :sub_account => true, :email => "subaccount@example.com")
      @project = Factory.create(:project, :company => @company)
      sign_in @user
    end

    it "should create a new timeslip" do
      timeslip = Factory.create(:timeslip, :project => @project, :user => @user)
      Timeslip.stub(:new) { timeslip }
      post :create
      response.should redirect_to(timeslips_path)
      sign_out @user
    end

    it "should render new when not saving the timeslip" do
      post :create, :task => { :project_id => @project.id }
      response.should render_template(:new)
      sign_out @user
    end
  end

  context :destroy do
    describe "manager" do
      before(:each) do
        @company = Factory.create(:company)
        @user = Factory.create(:user, :company => @company, :owns_company => true)
        @sub_user = Factory.create(:user, :company => @company, :sub_account => true, :email => "subaccount@example.com")
        @project = Factory.create(:project, :company => @company)
        @task = Factory.create(:task, :project_id => @project.id)
        @timeslip = Factory.create(:timeslip, :project => @project, :user => @user)
        sign_in @user
      end

      after(:each) do
        sign_out @user
      end

      it "should destroy the timeslip" do
        delete :destroy, :id => @timeslip.id
        Timeslip.exists?(@timeslip.id).should == false
      end

      it "should redirect to the timeslips path" do
        delete :destroy, :id => @timeslip.id
        response.should redirect_to(timeslips_path)
      end

      it "should show a successful message" do
        delete :destroy, :id => @timeslip.id
        flash[:notice].should == "The timeslip was successfully removed."
      end
    end

    describe "account removing another accounts timeslip" do
      before(:each) do
        @company = Factory.create(:company)
        @user = Factory.create(:user, :company => @company, :owns_company => true)
        @sub_user = Factory.create(:user, :company => @company, :sub_account => true, :email => "subaccount@example.com")
        @project = Factory.create(:project, :company => @company)
        @task = Factory.create(:task, :project_id => @project.id)
        @timeslip = Factory.create(:timeslip, :project => @project, :user => @user)
        sign_in @sub_user
      end

      after(:each) do
        sign_out @sub_user
      end

      it "should show a flash if there is an error" do
        delete :destroy, :id => @timeslip.id
        flash[:error].should == "You are not permitted to remove this timeslip."
      end

      it "should render index if there is an error" do
        delete :destroy, :id => @timeslip.id
        Timeslip.exists?(@timeslip.id).should == true
      end
    end
  end
end
