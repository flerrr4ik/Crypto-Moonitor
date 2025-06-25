Crypto Moonitor

Crypto Moonitor is a modern and lightweight iOS application for real-time cryptocurrency market tracking. It offers detailed market insights, interactive charting, price alert notifications, and exchange-level information in a clean, responsive interface.

Features
	•	Real-time data for the top 100 cryptocurrencies via CoinGecko API
	•	Inline mini-charts rendered directly in the list view
	•	Interactive line charts with selectable time ranges (1h, 24h, 7d, 30d, 90d)
	•	Persistent favorites management
	•	Price alert functionality with local notifications
	•	Background price monitoring using BGTaskScheduler
	•	Exchange data and top market pairs per cryptocurrency
	•	Modular codebase with improved separation of concerns
	•	Protocol-oriented abstraction for notification logic

Technologies Used
	•	Swift with UIKit
	•	CoinGecko API – for all cryptocurrency data
	•	Charts (DGCharts) – for dynamic graph rendering
	•	SDWebImage – for asynchronous image loading and caching
	•	UserNotifications Framework – for local notification delivery
	•	UserDefaults – for lightweight local persistence
	•	BGTaskScheduler – for background price polling
	•	Protocol-oriented programming – for flexible notification injection

Architecture

The app follows an MVC-based structure, with progressive separation via protocol conformance:

View Controllers
	•	MainListVC – handles display of live cryptocurrency data, mini-charts, and sorting
	•	DetailedCryptoVC – displays extended information, charts, social/media links, and market pairs

Services
	•	APIService – centralized class for API calls and JSON decoding
	•	FavoritesManager – singleton for managing favorite coins with persistent storage
	•	NotificationService – notification delivery logic abstracted via NotificationManaging protocol
	•	ChartService – reusable component for loading and rendering charts
	•	PriceAlertOperation – background price check logic executed in scheduled tasks

Protocols
	•	NotificationManaging – abstract interface to handle notifications, allowing for dependency injection and mocking
	•	Future services will continue adopting protocol-driven design for testability and modularity

Setup Instructions
	1.	Clone the repository
	2.	Open Crypto Moonitor.xcodeproj in Xcode
	3.	Build and run on a physical device or simulator
	4.	No API key is required — CoinGecko’s free public API is used

Planned Enhancements
	•	Background refresh logic using Core Data and URLSession background sessions
	•	Home screen widgets with live coin data
	•	Localization (English, Ukrainian)
	•	Enhanced dark mode visuals
	•	Chart overlays: volume, moving averages
	•	Modular refactoring to MVVM (in progress)

Author

Andrii Pyrskyi
GitHub: @flerrr4ik
