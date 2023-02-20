#[contract]
mod MyERC20 {
    use starknet::get_caller_address;
    struct Storage {
        name: felt,
        symbol: felt,
        decimals: u8,
        total_supply: u256,
        balances: LegacyMap::<felt, u256>,
        allowances: LegacyMap::<(felt, felt), u256>,
    }

    #[constructor]
    fn init(name: felt, symbol: felt, decimals: u8) {
        assert(decimals < 100_u8, 'Too many decimals');
        name::write(name);
        symbol::write(symbol);
        decimals::write(decimals);
    }

    #[external]
    fn mint(amount: u256, account: felt) {
        balances::write(account, balances::read(account) + amount);
        total_supply::write(total_supply::read() + amount);
        Transfer(0, account, amount);
    }

    #[external]
    fn burn(amount: u256) {
        let caller = get_caller_address();
        let balance = balances::read(caller);
        assert(balance - amount > 0, 'Balance too low to burn');
        balances::write(caller, balance - amount);
        total_supply::write(total_supply::read() - amount);
        Transfer(caller, 0, amount);
    }

    #[view]
    fn get_name() -> felt {
        name::read()
    }

    #[view]
    fn get_symbol() -> felt {
        symbol::read()
    }

    #[view]
    fn get_decimals() -> u8 {
        decimals::read()
    }

    #[view]
    fn get_total_supply() -> u256 {
        total_supply::read()
    }

    #[view]
    fn allowance(from: felt, to: felt) -> u256 {
        allowances::read((from, to))
    }

    #[view]
    fn balance_of(account: felt) -> u256 {
        balances::read(account)
    }

    #[external]
    fn approve(account: felt, amount: u256) -> bool {
        let caller = get_caller_address();
        allowances::write((caller, account), amount);
        Approval(caller, account, amount);
        return true;
    }

    #[external]
    fn transfer(_to: felt, _value: u256) -> bool {
        let sender = get_caller_address();
        assert(_to != 0, 'Cannot transfer to 0 address');
        balances::write(sender, balances::read(sender) - _value);
        balances::write(_to, balances::read(_to) + _value);
        Transfer(sender, _to, _value);
        true
    }

    #[external]
    fn transfer_from(_from: felt, _to: felt, _value: u256) -> bool {
        let sender = get_caller_address();
        assert(_to != 0, 'Cannot transfer to 0 address');
        let allowance = allowances::read((_from, sender));
        let new_amount = allowance - _value;
        assert(new_amount < 0, 'Allowance too low');
        allowances::write((_from, sender), new_amount);
        balances::write(_from, balances::read(_from) - _value);
        balances::write(_to, balances::read(_to) + _value);
        Transfer(_from, _to, _value);
        Approval(_from, sender, new_amount);
        true
    }


    #[event]
    fn Transfer(_from: felt, _to: felt, _value: u256) {}
    #[event]
    fn Approval(_owner: felt, _spender: felt, _value: u256) {}
}
