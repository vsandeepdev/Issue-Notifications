class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  GITHUB_APP_IDENTIFIER = 'id'
  PATH_TO_PRIVATE_KEY = '/path/to/key'
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(File.read(PATH_TO_PRIVATE_KEY))

  def receive
    payload = JSON.parse(request.body.read)

    if payload['action'] == 'opened' && payload['issue']
      issue = payload['issue']
      unless issue['body'].include?('Estimate:')
        remind_estimate(issue)
      end
    end

    head :ok
  end

  private

  def remind_estimate(issue)
    installation_id = issue['repository']['owner']['id']
    token = get_installation_access_token(installation_id)

    client = Octokit::Client.new(bearer_token: token)
    client.add_comment(issue['repository']['full_name'], issue['number'], 'Please provide an estimate in the format "Estimate: X days".')
  end

  def get_installation_access_token(installation_id)
    payload = {
      iat: Time.now.to_i,
      exp: Time.now.to_i + (10 * 60),
      iss: GITHUB_APP_IDENTIFIER
    }

    jwt = JWT.encode(payload, PRIVATE_KEY, 'RS256')
    client = Octokit::Client.new(bearer_token: jwt)
    client.create_app_installation_access_token(installation_id)[:token]
  end
end
  