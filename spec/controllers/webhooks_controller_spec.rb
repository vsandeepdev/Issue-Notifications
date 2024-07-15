# spec/controllers/webhooks_controller_spec.rb

require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe "#receive" do
    context "when issue is opened without 'Estimate:' in body" do
      it "reminds to add estimate" do
        # Simulate an issue opened event without 'Estimate:' in body
        issue_payload = {
          "action" => "opened",
          "issue" => {
            "body" => "This is a test issue"
          }
        }.to_json

        # Stub external service call (e.g., Octokit) for adding a comment
        allow_any_instance_of(Octokit::Client).to receive(:add_comment).and_return(true)

        request.headers['Content-Type'] = 'application/json'
        post :receive, body: issue_payload

        expect(response).to have_http_status(:ok)

        # Verify that a comment reminding to add estimate is added
        expect(Octokit::Client).to have_received(:add_comment).with(anything, "Please add an estimate to this issue.")
      end
    end

    context "when issue is opened with 'Estimate:' in body" do
      it "does not remind to add estimate" do
        # Simulate an issue opened event with 'Estimate:' in body
        issue_payload = {
          "action" => "opened",
          "issue" => {
            "body" => "Estimate: 2 days"
          }
        }.to_json

        allow_any_instance_of(Octokit::Client).to receive(:add_comment).and_return(true)

        request.headers['Content-Type'] = 'application/json'
        post :receive, body: issue_payload

        expect(response).to have_http_status(:ok)

        # Verify that no comment is added when 'Estimate:' is present in the issue body
        expect(Octokit::Client).not_to have_received(:add_comment)
      end
    end
  end
end
