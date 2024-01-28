require 'rails_helper'

RSpec.describe "Projects", type: :system do
  let!(:user){ FactoryBot.create(:user) }
  let!(:project) { FactoryBot.create(:project, owner: user) }

  before do
    sign_in user
  end
    
  scenario "user creates a new project" do
    visit root_path
    expect {
      click_link "New Project"
      fill_in "Name", with: "Test Project"
      fill_in "Description", with: "Trying out Capybara"
      click_button "Create Project"

      aggregate_failures do
        expect(page).to have_content "Project was successfully created"
        expect(page).to have_content "Test Project"
        expect(page).to have_content "Owner: #{user.name}"
      end
    }.to change(user.projects, :count).by(1)
  end

  scenario "user edit a project" do

    visit project_path(project)
    click_link "Edit"

    expect(page).to have_content "Editing project"
    expect(page).to have_content "Name"
    expect(page).to have_content "Description"
    expect(page).to have_content "Due on"

    fill_in "Name", with: "Test edit"
    fill_in "Description", with: "Ttying edit"

    click_button "Update Project"

    expect(page).to \
      have_content "Project was successfully updated."
    expect(current_path).to eq project_path(project)
  end

  scenario "user completes a project" do

    visit project_path(project)

    expect(page).to_not have_content "Completed"

    click_button "Complete"

    expect(project.reload.completed?).to be true
    expect(page).to \
      have_content "Congratulations, this project is complete!"
    expect(page).to have_content "Completed"
    expect(page).to_not have_button "Complete"
  end
end
