# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "chartkick" # @5.0.1
pin "chart.js" # @4.5.0
pin "date-fns" # @4.1.0
pin "chartjs-adapter-date-fns", to: "chartjs-adapter-date-fns.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4
