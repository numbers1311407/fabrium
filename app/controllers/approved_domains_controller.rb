class ApprovedDomainsController < ResourceController
  self.default_sort = {name: 'name', dir: 'asc'}
  permit_params :name
end
