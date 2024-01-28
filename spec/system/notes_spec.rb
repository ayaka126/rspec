require 'rails_helper'

RSpec.describe "Notes", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:project) {
    FactoryBot.create(:project,
      name: "RSpec tutorial",
      owner: user)
  }

  before do
    sign_in user
    visit project_path(project)
    click_link "Add Note"
    fill_in "Message", with: "My book cover"
    attach_file "Attachment", "#{Rails.root}/spec/files/attachment.jpg"
    click_button "Create Note"
  end

  scenario "user uploads an attachment" do
    expect(page).to have_content "Note was successfully created"
    expect(page).to have_content "My book cover"
    expect(page).to have_content "attachment.jpg (image/jpeg"
  end

  scenario "user edit a note" do
    within(".note-info") do
      click_link("Edit")
    end

    expect(page).to have_content "Editing note"
    expect(page).to have_content "Message"
    expect(page).to have_content "Attachment"
    expect(page).to have_button "Update Note"
    expect(page).to have_content "Cancel"

    fill_in "Message", with: "edit note"
    click_button "Update Note"

    expect(page).to have_content "Note was successfully updated."
    expect(page).to have_content "edit note"
  end

  scenario "user delete a note" , js: true do
    within(".note-info") do
      accept_alert("Are you sure?") do
        click_link("Delete")
      end
    end
    expect(page).to have_content "Note was successfully destroyed."
    expect(page).to_not have_content "edit note"
  end
end
