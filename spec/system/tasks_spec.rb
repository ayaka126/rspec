require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:project) {
    FactoryBot.create(:project,
      name: "RSpec tutorial",
      owner: user)
  }
  #task_nameを定義して"Finish RSpec tutorial"が何度も書かなくていいようにする
  let(:task_name) { "Finish RSpec tutorial" }
  let!(:task) { project.tasks.create!(name: task_name) }
  
  before do
    sign_in user
    go_to_project "RSpec tutorial"
  end

  # ユーザーがタスクの状態を切り替える
  scenario "user toggles a task", js: true do

    complete_task task_name
    expect_complete_task task_name

    undo_complete_task task_name
    expect_incomplete_task task_name
  end

  def go_to_project(name)
    visit root_path
    click_link name
  end

  def complete_task(task_name)
    check task_name
  end

  def undo_complete_task(task_name)
    uncheck task_name
  end

  def expect_complete_task(task_name)
    aggregate_failures do
      expect(page).to have_css "label.completed", text: task_name
      expect(task.reload).to be_completed
    end
  end

  def expect_incomplete_task(task_name)
    aggregate_failures do
      expect(page).to_not have_css "label.completed", text: task_name
      expect(task.reload).to_not be_completed
    end
  end

  scenario "user edit a task" do
    within("tr.task") do
      click_link("Edit")
    end

    expect(page).to have_content "Editing task"
    expect(page).to have_content "Name"
    expect(page).to have_content "Completed"
    expect(page).to have_button "Update Task"
    expect(page).to have_content "Cancel"

    fill_in "Name", with: "edit name"
    click_button "Update Task"

    expect(page).to have_content "Task was successfully updated."
    expect(page).to have_content "edit name"
  end

  scenario "user delete a task" , js: true do
    within("tr.task") do
      accept_alert("Are you sure?") do
        click_link("Delete")
      end
    end
    
    expect(page).to have_content "Task was successfully destroyed."
    expect(page).to_not have_content "edit name"

  end

  scenario "user add a task" do
    click_link "Add Task"

    expect(page).to have_content "New task"
    expect(page).to have_content "Name"

    fill_in "Name", with: "Test Task"
    click_button "Create Task"
    
    expect(page). to have_content "Task was successfully created."
  end

end
