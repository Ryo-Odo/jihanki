# irb
# load './jihanki.rb'
# vm = VendingMachine.new(1)
# 作成した自動販売機に100円を入れる
# vm.slot_money (100)
# 作成した自動販売機に入れたお金がいくらかを確認する（表示する）
# vm.current_slot_money
# 作成した自動販売機に入れたお金を返してもらう
# vm.return_money

#---------------------------------------------------------------------------------------------------
module Consumer
  #購入者用のモジュール
  MONEY = [10, 50, 100, 500, 1000].freeze

  def current_slot_money
    #0-3 投入金額総計を取得できる
    @slot_money
  end

  def slot_money(money)
    #0-1 お金の１つずつ投入できる
    #0-2 複数回投入できる
    #1-1 想定外のもの
    return false unless MONEY.include?(money)
    @slot_money += money
  end

  def return_money
    #0-4 払い戻し及び総計金額のリセット
    puts "\nお釣り#{@slot_money}円"
    @slot_money = 0
  end

  def cs_list
    #3-1 購入可能な商品一覧の取得
    #4-2 購入可能な商品一覧の取得
    i = 1
    puts "\n\n------------------------------------------------------------------------"
    puts "---------------------------いらっしゃいませ！---------------------------"
    puts "------------------------------------------------------------------------"
    @products.each{|product_name, price_stock|
      if price_stock[:stock] == 0
        #もし在庫がなかったら
        puts "\n#{product_name}　値段:#{price_stock[:price]}円 在庫:#{price_stock[:stock]} 在庫切れ"
      elsif @slot_money < price_stock[:price]
        #もし投入金額が足りなかったら
        puts "\n#{product_name}　値段:#{price_stock[:price]}円 在庫:#{price_stock[:stock]} お金が足りません"
      elsif @slot_money >= price_stock[:price] && price_stock[:stock] > 0
        #もし投入金額が足りており、在庫もあったら
        puts "\n#{product_name}　値段:#{price_stock[:price]}円 在庫:#{price_stock[:stock]} 購入可能"
      end
      i += 1
    }
    puts "------------------------------------------------------------------------"
    puts "投入残金額#{@slot_money}円"
    if @my_orders.length == 0
      puts "購入品：なし"
    else
      puts "購入品：#{@my_orders}"
    end
  end

  def buy(product_name)
    #3-2 ジュースの購入及び在庫数の変動
    #3-3 金額が足りない場合何もしない
    #5-1 釣り銭の出力
    product = @products[product_name]
    if product[:stock] == 0
      puts "在庫切れ"
    elsif @slot_money < product[:price]
      puts "お金が足りません"
      puts "\n投入残金額#{@slot_money}"
    elsif @slot_money >= product[:price] && product[:stock] > 0
      @products[product_name][:stock] = (@products[product_name][:stock]) - 1
      @slot_money = @slot_money - @products[product_name][:price]
      @sales_amount = @products[product_name][:price]
      @my_orders << product_name.to_s
      puts "\n#{product_name}購入完了"
    end
  end
end


#---------------------------------------------------------------------------------------------------
module Manager
  #管理者用のモジュール
  def start
    loop{
        self.cs_list
        #デフォルトで情報を表示
        puts "\nいらっしゃいませ！"
        puts "使用方法"
        puts "お金の投入：任意の金額を半角数字で入力しエンターキー　例 100円を投入するときは100"
        puts "商品購入:商品名を入力しエンターキー"
        puts "投入金の返金：返金　と入力しエンターキー"
        puts "買い物を終了するときは end と入力しエンターキー"

        user_input = gets.chomp
        p user_input
        case user_input
        when "10", "50", "100", "500", "1000"
          #お金の投入
          user_input = user_input.to_i
          self.slot_money(user_input)
        when "返金"
          #返金
          p "OK"
          self.return_money
        when "end"
          #ループから抜ける
          puts "\nご利用ありがとうございました"
          break
        when "mg mode"
          self.mg_mode
        else
          #商品の購入
          user_input = user_input.to_sym
          if @products.keys.include?(user_input)
            self.buy(user_input)
          else
            puts "有効な入力情報では有りません"
          end
        end
      }
  end

  def mg_mode
    loop {
      self.mg_list
      puts "\n管理モード中…"
      puts "任意の数字を入力してエンターキーを押して下さい"
      puts "すでにある商品補充：1"
      puts "新規商品の追加：2"
      puts "売上金の回収：3"
      puts "管理モードの終了：4"

      user_input = gets.chomp.to_i
      case user_input
      when 1
        self.addition_products
      when 2
        self.new_products
      when 3
        self.withdrawals
      when 4
        break
      end
    }
  end

  def mg_list
    #2-2 商品一覧の取得
    #3-4 売上金額取得
    puts "\n\n----------------------------------------------------------------------"
    puts "------------------------------管理モード------------------------------"
    puts "----------------------------------------------------------------------"
    @products.each{|product_name, price_stock|
      puts "\n#{product_name}　値段:#{price_stock[:price]}円 在庫:#{price_stock[:stock]}個"
    }
    puts "----------------------------------------------------------------------"
    puts "売上金額#{@sales_amount}円"
  end

  def withdrawals
    #売上金額の回収
    puts "\n売上金額#{@sales_amount}円を回収しました"
    @sales_amount = 0
  end

  def addition_products
    #既存商品の追加
    puts "追加する既存の商品名を入力して下さい"
    product_name = gets.chomp.to_sym
    if @products.keys.include?(product_name)
      puts "#{product_name}の在庫数：#{@products[product_name][:stock]}個"
      puts "追加する個数を半角数字で入力して下さい"
      addition_stock = gets.chomp.to_i
      @products[product_name][:stock] = (@products[product_name][:stock]) + addition_stock
      puts "\n#{product_name}を#{addition_stock}個追加しました"
      puts "#{product_name}の在庫数：#{@products[product_name][:stock]}個"
    else
      puts "入力された商品がありません"
    end
  end

  def new_products
    puts "新規に追加する商品名を入力して下さい"
    product_name = gets.chomp.to_sym
    puts "値段を半角数字で入力して下さい"
    product_price = gets.chomp.to_i
    puts "追加する個数を半角数字で入力して下さい"
    product_stock = gets.chomp.to_i
    @products[product_name] = {price: product_price, stock: product_stock}
    puts "\n商品追加完了"
    puts "「#{product_name}」値段:#{product_price}円 在庫:#{product_stock}個"
  end

end
#---------------------------------------------------------------------------------------------------

class VendingMachine
  #メイン
  require "./drink.rb"
  include Consumer
  include Manager


  def initialize(i)
    @slot_money = 0
    @sales_amount = 0
    @my_orders = []

    @no_1 = Drink.new
    p @no_1
    case i
      #インスタンス作成時、自動販売機内の初期商品を引数で選択する
    when 1
      @products = {
        #2-1 ジュースを格納している
        #4-1 ジュースを3種類格納している
        コーラ: {price: 120, stock: 5},
        レッドブル: {price: 200, stock: 5},
        水: {price: 100, stock: 5}
      }
    when 2
      @products = {
        メロンパン: {price: 120, stock: 5},
        カロリーメイト: {price: 200, stock: 5},
        カップラーメン: {price: 150, stock: 5}
      }
    end
  end
end
