require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'respond_with' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      build_response
      @matcher = respond_with(:error)
    end

    it 'should contain a description message' do
      respond_with(404).description.should == 'respond with 404'
      respond_with(:error).description.should == 'respond with error'
      respond_with(500..599).description.should == 'respond with 500..599'

      @matcher.body(/anything/)
      @matcher.description.should == 'respond with error and with body /anything/'

      @matcher.content_type(Mime::XML).matches?(@controller)
      @matcher.description.should == 'respond with error, with body /anything/, and with content type "application/xml"'
    end

    it 'should set status_matches? message' do
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected to respond with status :error, got 200'
    end

    it 'should set content_type_matches? message' do
      @matcher = respond_with(:success)
      @matcher.body(/anything/).matches?(@controller)
      @matcher.failure_message.should == 'Expected to respond with body /anything/, got " "'
    end

    it 'should set content_type_matches? message' do
      @matcher = respond_with(:success)
      @matcher.content_type(Mime::XML).matches?(@controller)
      @matcher.failure_message.should == 'Expected to respond with content type "application/xml", got "text/html"'
    end
  end

  describe 'matcher' do

    describe 'on success' do
      before(:each){ build_response }

      it { should respond_with(200) }
      it { should respond_with(:ok) }
      it { should respond_with(:success) }
      it { should respond_with(200..299) }

      it { should respond_with(200, :content_type => Mime::HTML) }
      it { should respond_with(:ok, :content_type => Mime::HTML) }
      it { should respond_with(:success, :content_type => Mime::HTML) }
      it { should respond_with(200..299, :content_type => Mime::HTML) }

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

    describe 'respond_with_body' do
      before(:each) { build_response { respond_to{ |format| format.xml { render :xml => [].to_xml } } } }

      it { should respond_with_body(%{<?xml version="1.0" encoding="UTF-8"?>\n<nil-classes type="array"/>\n}) }
      it { should respond_with_body(/xml/)       }
      it { should respond_with_body{/xml/}       }
      it { should respond_with_body proc{/xml/}  }
      it { should_not respond_with_body('html')  }
      it { should_not respond_with_body(/html/)  }
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

    describe 'respond_with_content_type' do
      describe 'and Mime::HTML' do
        before(:each){ build_response { render :action => :new } }

        it { should respond_with_content_type(:html) }
        it { should respond_with_content_type(/html/) }
        it { should respond_with_content_type(Mime::HTML) }
        it { should respond_with_content_type('text/html') }

        it { should_not respond_with_content_type(:xml) }
        it { should_not respond_with_content_type(/xml/) }
        it { should_not respond_with_content_type(Mime::XML) }
        it { should_not respond_with_content_type('application/xml') }
      end

      describe 'and Mime::XML' do
        before(:each) { build_response { respond_to{ |format| format.xml } } }

        it { should respond_with_content_type(:xml) }
        it { should respond_with_content_type(/xml/) }
        it { should respond_with_content_type(Mime::XML) }
        it { should respond_with_content_type('application/xml') }

        it { should_not respond_with_content_type(:html) }
        it { should_not respond_with_content_type(/html/) }
        it { should_not respond_with_content_type(Mime::HTML) }
        it { should_not respond_with_content_type('text/html') }
      end
    end

  end

  describe 'macro' do

    describe 'on success' do
      before(:each){ build_response }

      should_respond_with 200
      should_respond_with :ok
      should_respond_with :success
      should_respond_with 200..299

      should_respond_with 200, :content_type => Mime::HTML
      should_respond_with :ok, :content_type => Mime::HTML
      should_respond_with :success, :content_type => Mime::HTML
      should_respond_with 200..299, :content_type => Mime::HTML

      should_respond_with 200 do |m|
        m.body /\s*/
        m.content_type Mime::HTML
      end

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

    describe 'respond_with_body' do
      before(:each) { build_response { respond_to{ |format| format.xml { render :xml => [].to_xml } } } }

      should_respond_with_body %{<?xml version="1.0" encoding="UTF-8"?>\n<nil-classes type="array"/>\n}
      should_respond_with_body /xml/
      should_not_respond_with_body 'html'
      should_not_respond_with_body /html/
    end

    describe 'respond_with_content_type' do
      describe 'and Mime::HTML' do
        before(:each){ build_response { render :action => :new } }

        should_respond_with_content_type :html
        should_respond_with_content_type /html/
        should_respond_with_content_type Mime::HTML
        should_respond_with_content_type 'text/html'

        should_not_respond_with_content_type :xml
        should_not_respond_with_content_type /xml/
        should_not_respond_with_content_type Mime::XML
        should_not_respond_with_content_type 'application/xml'
      end

      describe 'and Mime::XML' do
        before(:each) { build_response { respond_to{ |format| format.xml } } }

        should_respond_with_content_type :xml
        should_respond_with_content_type /xml/
        should_respond_with_content_type Mime::XML
        should_respond_with_content_type 'application/xml'

        should_not_respond_with_content_type :html
        should_not_respond_with_content_type /html/
        should_not_respond_with_content_type Mime::HTML
        should_not_respond_with_content_type 'text/html'
      end
    end

  end

  generate_macro_stubs_specs_for(:respond_with, 200)
  generate_macro_stubs_specs_for(:respond_with_body, /xml/)
  generate_macro_stubs_specs_for(:respond_with_content_type, Mime::HTML)
end
