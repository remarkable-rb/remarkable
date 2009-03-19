require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'respond_with' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = respond_with(:error)
    end

    it 'should contain a description message' do
      respond_with(404).description.should == 'respond with 404'
      respond_with(:error).description.should == 'respond with "error"'
      respond_with(500..599).description.should == 'respond with 500..599'
    end

    it 'should set status_match? message' do
      build_response
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected to respond with "error", got 200'
    end
  end

  describe 'matcher' do

    describe 'on success' do
      before(:each){ build_response }

      it { should respond_with(200) }
      it { should respond_with(:ok) }
      it { should respond_with(:success) }
      it { should respond_with(200..299) }

      it { should_not respond_with(404) }
      it { should_not respond_with(:not_found) }
      it { should_not respond_with(300..400) }
    end

    describe 'on missing' do
      before(:each){ build_response { render :text => "404 Not Found", :status => 404 } }

      it { should respond_with(404) }
      it { should respond_with(:not_found) }
      it { should respond_with(:missing) }
      it { should respond_with(400..405) }

      it { should_not respond_with(302) }
      it { should_not respond_with(:found) }
      it { should_not respond_with(:redirect) }
      it { should_not respond_with(300..305) }
    end

    describe 'on redirect' do
      before(:each){ build_response { redirect_to project_tasks_url(1) } }

      it { should respond_with(302) }
      it { should respond_with(:found) }
      it { should respond_with(:redirect) }
      it { should respond_with(300..305) }

      it { should_not respond_with(200) }
      it { should_not respond_with(:ok) }
      it { should_not respond_with(:success) }
      it { should_not respond_with(200..299) }
    end

  end

  describe 'macro' do

    describe 'on success' do
      before(:each){ build_response }

      should_respond_with 200
      should_respond_with :ok
      should_respond_with :success
      should_respond_with 200..299

      should_not_respond_with 404
      should_not_respond_with :not_found
      should_not_respond_with 300..400
    end

    describe 'on missing' do
      before(:each){ build_response { render :text => "404 Not Found", :status => 404 } }

      should_respond_with 404
      should_respond_with :not_found
      should_respond_with :missing
      should_respond_with 400..405

      should_not_respond_with 302
      should_not_respond_with :found
      should_not_respond_with :redirect
      should_not_respond_with 300..305
    end

    describe 'on redirect' do
      before(:each){ build_response { redirect_to project_tasks_url(1) } }

      should_respond_with 302
      should_respond_with :found
      should_respond_with :redirect
      should_respond_with 300..305

      should_not_respond_with 200
      should_not_respond_with :ok
      should_not_respond_with :success
      should_not_respond_with 200..299
    end

  end
end
