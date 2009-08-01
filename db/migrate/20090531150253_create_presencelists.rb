class CreatePresencelists < ActiveRecord::Migration
  def self.up
    create_table :presencelists do |t|
      t.integer :course_id
      t.integer :pupil_id
      t.date :date
      t.integer :status
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :presencelists
  end
end
