class CreateShortenedUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :shortened_urls do |t|
      t.integer :user_id
      t.text :original_url
      t.timestamps
    end
  end
end
