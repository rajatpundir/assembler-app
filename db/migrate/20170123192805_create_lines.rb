class CreateLines < ActiveRecord::Migration[5.0]
  
	def change
    create_table :lines do |t|
    	t.string :address
    	t.string :data, :null => false
  		t.string :code,:null => false, :default => ""
  		t.references :program
		t.timestamps null: false
    end
  end

end
