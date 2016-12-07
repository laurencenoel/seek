module Deprecated
  class Specimen < ActiveRecord::Base
    set_table_name 'deprecated_specimens'

    has_many :deprecated_samples, class_name: 'Deprecated::Sample', foreign_key: 'deprecated_specimen_id'
    has_many :deprecated_treatments, class_name: 'Deprecated::Treatment', foreign_key: 'deprecated_specimen_id'
    has_and_belongs_to_many :projects, foreign_key: 'deprecated_specimen_id', join_table: 'deprecated_specimens_projects'

    def encode_with(coder)
      h = super(coder)
      h['deprecated_samples'] = deprecated_samples
      h['deprecated_treatments'] = deprecated_treatments
      h['project_ids'] = project_ids
      h
    end
  end
end
