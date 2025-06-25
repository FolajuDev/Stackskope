# StackScope Analytics Platform


> A comprehensive blockchain analytics platform providing deep insights into Stacks network activity and DeFi metrics through smart contract-powered data collection and analysis.


## 🚀 Overview

StackScope is a next-generation blockchain analytics platform built specifically for the Stacks ecosystem. It provides real-time insights into network activity, DeFi protocol performance, token metrics, and overall network health through a decentralized smart contract architecture.

### Key Features

- **📊 DeFi Analytics**: Track Total Value Locked (TVL) across protocols
- **💱 Trading Metrics**: Monitor daily volume and transaction patterns  
- **🪙 Token Intelligence**: Comprehensive token performance tracking
- **🔍 Protocol Insights**: Deep dive into protocol usage statistics
- **🌐 Network Health**: Real-time network performance monitoring
- **⚡ Real-time Data**: Live updates powered by smart contracts
- **🔐 Decentralized**: Fully on-chain data storage and verification

## 🏗️ Architecture

StackScope consists of three main components:

1. **Smart Contract Layer** - Clarity-based data collection and storage
2. **Analytics Engine** - Data processing and metric calculation
3. **Frontend Dashboard** - User-friendly interface for data visualization

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │◄──►│  Analytics       │◄──►│  Smart Contract │
│   Dashboard     │    │  Engine          │    │  (Clarity)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📋 Prerequisites
- Basic understanding of Clarity smart contracts

## 🛠️ Installation


### 1. Install Dependencies

```bash
# Install Clarinet globally
npm install -g @hirosystems/clarinet

# Install project dependencies
npm install
```

### 2. Initialize Clarinet Project

```bash
clarinet new stackscope-analytics
cd stackscope-analytics
```

### 3. Deploy Smart Contract

```bash
# Copy the contract to contracts directory
cp ../contracts/stackscope-analytics.clar contracts/

# Deploy to local testnet
clarinet integrate

# Deploy to testnet
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

## 📖 Usage

### Smart Contract Integration

#### Recording Protocol TVL

```clarity
;; Record TVL for a DeFi protocol
(contract-call? .stackscope-analytics record-protocol-tvl 
    "alex-defi" 
    u1000000000  ;; 1,000 STX in microSTX
    block-height)
```

#### Tracking Daily Volume

```clarity
;; Record daily trading metrics
(contract-call? .stackscope-analytics record-daily-volume
    "2024-01-15"
    u5000000000   ;; Total volume
    u150          ;; Transaction count
    u75)          ;; Unique addresses
```

#### Monitoring Token Performance

```clarity
;; Record token analytics
(contract-call? .stackscope-analytics record-token-metrics
    'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.arkadiko-token
    block-height
    u2500000      ;; Price in microSTX
    u10000000     ;; 24h volume
    u50000000000  ;; Market cap
    u1250)        ;; Holders count
```

### API Integration

#### JavaScript/TypeScript Example

```javascript
import { StacksMainnet } from '@stacks/network';
import { callReadOnlyFunction, cvToJSON } from '@stacks/transactions';

// Get protocol TVL
async function getProtocolTVL(protocol, blockHeight) {
  const result = await callReadOnlyFunction({
    contractAddress: 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR',
    contractName: 'stackscope-analytics',
    functionName: 'get-protocol-tvl',
    functionArgs: [stringAsciiCV(protocol), uintCV(blockHeight)],
    network: new StacksMainnet(),
  });
  
  return cvToJSON(result);
}

// Usage
const tvlData = await getProtocolTVL('alex-defi', 123456);
console.log('Protocol TVL:', tvlData);
```

### Data Querying

#### Get Platform Statistics

```bash
# Using Stacks CLI
stx call_read_only_fn SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.stackscope-analytics get-platform-stats
```

#### Query Historical Data

```javascript
// Get daily volume for specific date
const volumeData = await callReadOnlyFunction({
  contractAddress: 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR',
  contractName: 'stackscope-analytics',
  functionName: 'get-daily-volume',
  functionArgs: [stringAsciiCV('2024-01-15')],
  network: new StacksMainnet(),
});
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# Network Configuration
STACKS_NETWORK=mainnet
CONTRACT_ADDRESS=SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR
CONTRACT_NAME=stackscope-analytics

# API Configuration
API_PORT=3000
CORS_ORIGIN=http://localhost:3000

# Database (optional for caching)
REDIS_URL=redis://localhost:6379
POSTGRES_URL=postgresql://user:pass@localhost:5432/stackscope
```

### Contract Configuration

```toml
# Clarinet.toml
[project]
name = "stackscope-analytics"
requirements = []
telemetry = false
cache_dir = ".cache"

[contracts.stackscope-analytics]
path = "contracts/stackscope-analytics.clar"
depends_on = []

[repl.analysis]
passes = ["check_checker"]

[[repl.analysis.check_checker.strict]]
trusted-sender = false
trusted-caller = false
callee-filter = false
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/stackscope-analytics_test.ts

# Run with coverage
clarinet test --coverage
```

### Example Test

```typescript
import { describe, expect, it } from "vitest";

describe("StackScope Analytics", () => {
  it("should record protocol TVL correctly", () => {
    const result = simnet.callPublicFn(
      "stackscope-analytics",
      "record-protocol-tvl",
      [Cl.stringAscii("test-protocol"), Cl.uint(1000000), Cl.uint(100)],
      address1
    );
    
    expect(result.result).toBeOk(Cl.bool(true));
  });

  it("should retrieve recorded metrics", () => {
    const result = simnet.callReadOnlyFn(
      "stackscope-analytics",
      "get-protocol-tvl",
      [Cl.stringAscii("test-protocol"), Cl.uint(100)],
      address1
    );
    
    expect(result.result).toBeSome();
  });
});
```

## 📊 Data Models

### Protocol TVL Structure

```typescript
interface ProtocolTVL {
  protocol: string;
  blockHeight: number;
  tvlAmount: bigint;
  timestamp: number;
  reporter: string;
}
```

### Daily Volume Structure

```typescript
interface DailyVolume {
  date: string; // YYYY-MM-DD
  totalVolume: bigint;
  transactionCount: number;
  uniqueAddresses: number;
  lastUpdated: number;
}
```

### Token Metrics Structure

```typescript
interface TokenMetrics {
  tokenContract: string;
  blockHeight: number;
  price: bigint; // in microSTX
  volume24h: bigint;
  marketCap: bigint;
  holdersCount: number;
  timestamp: number;
}
```

## 🔐 Security

### Access Control

The smart contract implements a multi-layered security model:

- **Owner Controls**: Administrative functions restricted to contract owner
- **Authorized Reporters**: Data submission limited to verified reporters  
- **Input Validation**: All inputs validated before storage
- **Emergency Controls**: Analytics can be disabled in emergency situations

### Best Practices

- Always validate reporter authorization before trusting data
- Implement rate limiting for data submission
- Use time-weighted averages for price calculations
- Regularly audit authorized reporters list

## 🚀 Deployment

### Testnet Deployment

```bash
# Generate deployment plan
clarinet deployments generate --testnet

# Apply deployment
clarinet deployments apply --testnet
```

### Mainnet Deployment

```bash
# Generate mainnet deployment plan
clarinet deployments generate --mainnet

# Review and apply
clarinet deployments apply --mainnet
```

### Post-Deployment Setup

1. Add authorized reporters
2. Configure platform fees
3. Test data recording functions
4. Set up monitoring and alerts

## 📈 Metrics Tracked

### DeFi Protocols
- Total Value Locked (TVL)
- Active users (24h, 7d, 30d)
- Transaction volumes
- Fee collection
- Yield rates

### Network Activity
- Daily transaction count
- Unique active addresses
- Block production metrics
- Gas fee trends
- Smart contract deployments

### Token Analytics
- Price movements
- Trading volumes
- Market capitalization
- Holder distribution
- Liquidity metrics
