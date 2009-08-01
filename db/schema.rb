# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090620125926) do

  create_table "courselists", :force => true do |t|
    t.integer  "course_id"
    t.integer  "pupil_id"
    t.date     "register"
    t.date     "quit"
    t.boolean  "canceled"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.integer  "teacher_id"
    t.integer  "subject_id"
    t.integer  "room_id"
    t.time     "start"
    t.time     "duration"
    t.integer  "weekday"
    t.boolean  "coursetype"
    t.boolean  "honorartype"
    t.decimal  "honorar",     :precision => 8, :scale => 2
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "presencelists", :force => true do |t|
    t.integer  "course_id"
    t.integer  "pupil_id"
    t.date     "date"
    t.integer  "status"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pupils", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone"
    t.date     "birthday"
    t.boolean  "gender"
    t.integer  "flags"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "size"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.datetime "date"
    t.integer  "room_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachers", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone"
    t.date     "birthday"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone"
    t.date     "birthday"
    t.text     "comment"
  end

end
