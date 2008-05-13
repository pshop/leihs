class CreateContractLines < ActiveRecord::Migration
  def self.up
    create_table :contract_lines do |t|
      t.belongs_to :contract
      t.belongs_to :item, :null => true
      t.belongs_to :order_line, :null => true
      t.integer :quantity # TODO
      t.date :start_date
      t.date :end_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contract_lines
  end
end
