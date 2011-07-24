class CreateVolumes < ActiveRecord::Migration

  def self.up
    create_table :volumes do |t|
      t.string :name, :directory, :protocole
      t.text   :description

      t.timestamps
    end
  end

  def self.down
    drop_table :volumes
  end

end
