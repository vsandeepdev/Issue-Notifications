# GitHub Issue Reminder App

This GitHub app automatically reminds issue creators to provide a time estimate if it's missing.

## Requirements

- Ruby 3.1.2
- Rails 6.1.7
- Bundler
- Smee.io

## Setup

1. Clone the repository.
2. Install dependencies:
    `bundle install`
3. Create a GitHub App and generate a private key.
4. Create a `.env` file in the root of the project.
4. Add the following environment variables:
    ```
    GITHUB_APP_IDENTIFIER=your_app_id
    PATH_TO_PRIVATE_KEY=path_to_your_private_key.pem
    ```
5. Run Smee to forward payloads to your local app:
    `smee -u YOUR_SMEE_URL -t http://localhost:3000/webhooks/receive`
6. Start the Rails server:
    `rails server`

## Usage

Once installed and running, the GitHub App will automatically add comments to newly opened issues that do not contain an "Estimate:" in their body.
