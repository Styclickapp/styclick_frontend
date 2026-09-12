import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/core/services/cart_service.dart';
import 'package:stylclick/core/services/profile_service.dart';
import 'checkout_payment.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String fullName = 'User';
  String address = 'No Address Provided';
  String phone = 'No Phone Number';
  String state = '';

  String? selectedState;
  String? selectedCity;

  List<String> states = ['Lagos', 'Abuja', 'Oyo', 'Kano', 'Rivers'];
  List<String> cities = ['Ikeja', 'Garki', 'Ibadan', 'Kano City', 'Port Harcourt'];

  bool status = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      final fName = getStringAsync('fName').isNotEmpty ? getStringAsync('fName') : getStringAsync('first_name');
      final lName = getStringAsync('lName').isNotEmpty ? getStringAsync('lName') : getStringAsync('last_name');
      final cachedFull = '$fName $lName'.trim();
      if (cachedFull.isNotEmpty) fullName = cachedFull;
      final cachedAddress = getStringAsync('address').isNotEmpty ? getStringAsync('address') : getStringAsync('street');
      if (cachedAddress.isNotEmpty) address = cachedAddress;
      final cachedPhone = getStringAsync('phone').isNotEmpty ? getStringAsync('phone') : getStringAsync('phone_number');
      if (cachedPhone.isNotEmpty) phone = cachedPhone;
      final cachedState = getStringAsync('state');
      if (cachedState.isNotEmpty) state = cachedState;
    });

    try {
      final res = await ProfileService.instance.fetchProfile();
      if (res.status == true && res.data != null) {
        final pData = res.data!['data'] ?? res.data!['user'] ?? res.data!;
        if (pData is Map) {
          final apiFn = pData['first_name'] ?? pData['firstname'] ?? pData['fName'] ?? '';
          final apiLn = pData['last_name'] ?? pData['lastname'] ?? pData['lName'] ?? '';
          final apiPh = pData['phone'] ?? pData['phone_number'] ?? '';
          final apiAddr = pData['address'] ?? '';
          final apiState = pData['state']?.toString() ?? '';

          setState(() {
            final apiFull = '$apiFn $apiLn'.trim();
            if (apiFull.isNotEmpty) fullName = apiFull;
            if (apiPh.isNotEmpty) phone = apiPh;
            if (apiAddr.isNotEmpty) address = apiAddr;
            if (apiState.isNotEmpty) state = apiState;
          });
        }
      }
    } catch (e) {
      log('[CHECKOUT] Remote profile load log: $e');
    }
  }

  Widget _buildStepIndicator(int currentStep) {
    return Container(
      color: cream,
      padding: EdgeInsets.only(left: 17.w, right: 17.w, bottom: 16.h, top: 4.h),
      child: Row(
        children: [
          _buildStepItem('Delivery', 0, currentStep),
          _buildStepLine(0, currentStep),
          _buildStepItem('Payment', 1, currentStep),
          _buildStepLine(1, currentStep),
          _buildStepItem('Summary', 2, currentStep),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, int stepIndex, int currentStep) {
    bool isActive = stepIndex == currentStep;
    bool isCompleted = stepIndex < currentStep;

    return Container(
      height: 32.h,
      width: 90.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: isActive
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, primaryGradient],
              )
            : null,
        color: isActive ? null : (isCompleted ? primary.withOpacity(0.1) : const Color(0xfff4f4f5)),
        border: Border.all(
          color: isActive ? Colors.transparent : (isCompleted ? primary.withOpacity(0.3) : sand),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? white : (isCompleted ? primary : textLight),
            fontSize: 12.sp,
            fontFamily: cinta,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(int afterStep, int currentStep) {
    bool isCompleted = afterStep < currentStep;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        height: 2.h,
        color: isCompleted ? primary : sand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItemModel>>(
      valueListenable: CartService.instance.itemsNotifier,
      builder: (context, cartItems, child) {
        final selectedItems = cartItems.where((item) => item.isSelected).toList();
        final itemsToDisplay = selectedItems.isNotEmpty ? selectedItems : cartItems;
        final subtotal = itemsToDisplay.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
        final deliveryFee = subtotal > 0 ? 2500.0 : 0.0;
        final grandTotal = subtotal + deliveryFee;

        return Scaffold(
          backgroundColor: cream,
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 17.w, right: 17.w, bottom: 17.h),
              child: InkWell(
                onTap: itemsToDisplay.isEmpty
                    ? () => toast('Your cart is empty')
                    : () async {
                        const CheckoutPaymentPage(isPayment: true).launch(context);
                      },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primaryGradient],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(110.h),
            child: AppBar(
              elevation: 0,
              backgroundColor: cream,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.height,
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: white,
                              shape: BoxShape.circle,
                              border: Border.all(color: sand),
                            ),
                            child: Icon(Icons.arrow_back, color: ink, size: 20.sp),
                          ),
                        ),
                        16.width,
                        Text(
                          'Checkout',
                          style: TextStyle(
                            fontFamily: cinta,
                            color: ink,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.h),
                child: _buildStepIndicator(0),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Address Details',
                      style: TextStyle(
                        color: ink,
                        fontSize: 15.sp,
                        fontFamily: cinta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        changeAddress(context);
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(
                          color: primary,
                          fontSize: 14.sp,
                          fontFamily: cinta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                12.height,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: sand),
                    boxShadow: [
                      BoxShadow(
                        color: ink.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          color: ink,
                          fontSize: 14.sp,
                          fontFamily: cinta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      8.height,
                      Text(
                        state.isNotEmpty ? '$address, $state State' : address,
                        style: TextStyle(
                          color: textLight,
                          fontSize: 13.sp,
                          fontFamily: cinta,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      8.height,
                      Text(
                        phone,
                        style: TextStyle(
                          color: textLight,
                          fontSize: 13.sp,
                          fontFamily: cinta,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                24.height,
                Text(
                  'Shipment Details',
                  style: TextStyle(
                    color: ink,
                    fontSize: 15.sp,
                    fontFamily: cinta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                12.height,
                itemsToDisplay.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Text(
                            'No items selected for checkout',
                            style: TextStyle(fontFamily: cinta, color: textLight, fontSize: 14.sp),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemsToDisplay.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = itemsToDisplay[index];
                          final itemDeliveryShare = deliveryFee / itemsToDisplay.length;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: sand),
                                boxShadow: [
                                  BoxShadow(
                                    color: ink.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Package ${index + 1} of ${itemsToDisplay.length}',
                                    style: TextStyle(
                                      color: ink,
                                      fontSize: 14.sp,
                                      fontFamily: cinta,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  8.height,
                                  Text(
                                    '${item.quantity}x ${item.name} (${item.size})',
                                    style: TextStyle(
                                      color: textLight,
                                      fontSize: 13.sp,
                                      fontFamily: cinta,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  8.height,
                                  Row(
                                    children: [
                                      Text(
                                        'Seller:',
                                        style: TextStyle(
                                          color: primary,
                                          fontSize: 13.sp,
                                          fontFamily: cinta,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      6.width,
                                      Expanded(
                                        child: Text(
                                          item.storeName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: ink,
                                            fontSize: 13.sp,
                                            fontFamily: cinta,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  8.height,
                                  Text(
                                    'Delivery: 2-3 working days',
                                    style: TextStyle(
                                      color: textLight,
                                      fontSize: 13.sp,
                                      fontFamily: cinta,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  8.height,
                                  Row(
                                    children: [
                                      Text(
                                        'Delivery fee:',
                                        style: TextStyle(
                                          color: primary,
                                          fontSize: 13.sp,
                                          fontFamily: cinta,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      6.width,
                                      Expanded(
                                        child: Text(
                                          'NGN ${formatPriceNoDecimal(itemDeliveryShare.toInt())}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: ink,
                                            fontSize: 13.sp,
                                            fontFamily: cinta,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                12.height,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: sand),
                    boxShadow: [
                      BoxShadow(
                        color: ink.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(
                              fontFamily: cinta,
                              fontSize: 14.sp,
                              color: textLight,
                            ),
                          ),
                          Text(
                            'NGN ${formatPriceNoDecimal(subtotal.toInt())}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                      12.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery fee',
                            style: TextStyle(
                              fontFamily: cinta,
                              fontSize: 14.sp,
                              color: textLight,
                            ),
                          ),
                          Text(
                            'NGN ${formatPriceNoDecimal(deliveryFee.toInt())}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(color: sand, thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontFamily: cinta,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          Text(
                            'NGN ${formatPriceNoDecimal(grandTotal.toInt())}',
                            style: GoogleFonts.montserrat(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  changeAddress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      backgroundColor: cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Change Address',
                  style: TextStyle(
                    fontFamily: cinta,
                    fontSize: 18.sp,
                    color: ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              20.height,
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: sand),
                ),
                child: Row(
                  children: [
                    Radio(
                      value: 0,
                      activeColor: primary,
                      groupValue: 0,
                      onChanged: (value) {},
                    ),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontFamily: cinta,
                          color: ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              20.height,
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  addAddress(context);
                },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      'Add New Address',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              12.height,
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primaryGradient],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Save Address',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              24.height,
            ],
          ),
        );
      },
    );
  }

  addAddress(BuildContext context) {
    final nameController = TextEditingController(text: fullName == 'User' ? '' : fullName);
    final addressController = TextEditingController();
    final phoneController = TextEditingController(text: phone == 'No Phone Number' ? '' : phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      backgroundColor: cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Add New Address',
                    style: TextStyle(
                      fontFamily: cinta,
                      fontSize: 18.sp,
                      color: ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                20.height,
                CustomTextField(
                  controller: nameController,
                  label: 'Full Name',
                  hintText: 'Enter full name',
                ),
                20.height,
                CustomTextField(
                  controller: addressController,
                  label: 'New Address',
                  hintText: 'Enter new address',
                ),
                20.height,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'State',
                            style: GoogleFonts.montserrat(
                              fontSize: 11.sp,
                              color: textLight,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          6.height,
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: sand),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedState,
                                dropdownColor: cream,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: textLight, size: 20.sp),
                                hint: Text('Select State', style: TextStyle(fontFamily: cinta, color: textLight.withOpacity(0.5), fontSize: 14.sp)),
                                items: states.map((state) {
                                  return DropdownMenuItem<String>(
                                    value: state,
                                    child: Text(state, style: TextStyle(fontFamily: cinta, color: ink, fontSize: 14.sp)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedState = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'City',
                            style: GoogleFonts.montserrat(
                              fontSize: 11.sp,
                              color: textLight,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          6.height,
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: sand),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCity,
                                dropdownColor: cream,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: textLight, size: 20.sp),
                                hint: Text('Select City', style: TextStyle(fontFamily: cinta, color: textLight.withOpacity(0.5), fontSize: 14.sp)),
                                items: cities.map((city) {
                                  return DropdownMenuItem<String>(
                                    value: city,
                                    child: Text(city, style: TextStyle(fontFamily: cinta, color: ink, fontSize: 14.sp)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCity = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                20.height,
                CustomTextField(
                  controller: phoneController,
                  label: 'Phone number',
                  hintText: 'Enter phone number',
                  textInputType: TextInputType.phone,
                ),
                20.height,
                Row(
                  children: [
                    FlutterSwitch(
                      width: 48.0,
                      height: 24.0,
                      inactiveColor: const Color(0xffd1d1d1),
                      activeColor: primary,
                      toggleSize: 16.0,
                      value: status,
                      borderRadius: 30.0,
                      padding: 4.0,
                      onToggle: (val) {
                        setState(() {
                          status = val;
                        });
                      },
                    ),
                    12.width,
                    Expanded(
                      child: Text(
                        'Set the new address as default',
                        style: TextStyle(
                          color: ink,
                          fontSize: 13.sp,
                          fontFamily: cinta,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
                24.height,
                InkWell(
                  onTap: () async {
                    final name = nameController.text.trim();
                    final addr = addressController.text.trim();
                    final ph = phoneController.text.trim();
                    final st = selectedState ?? '';
                    final ct = selectedCity ?? '';

                    if (name.isEmpty || addr.isEmpty || ph.isEmpty) {
                      toast('Please fill all fields');
                      return;
                    }

                    try {
                      final res = await ProfileService.instance.updateProfile(
                        fullName: name,
                        address: addr,
                        city: ct,
                        state: st,
                        country: 'Nigeria',
                      );
                      if (res.status == true) {
                        await setValue('phone', ph);
                        await setValue('first_name', name.split(' ').first);
                        await setValue('last_name', name.split(' ').length > 1 ? name.split(' ')[1] : '');
                        await setValue('address', addr);
                        await setValue('state', st);
                        toast('Address saved successfully');
                        _loadUserProfile();
                        Navigator.pop(context);
                      } else {
                        toast(res.message ?? 'Failed to update address');
                      }
                    } catch (e) {
                      toast('An error occurred: $e');
                    }
                  },
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primaryGradient],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Save Address',
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 16.sp,
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                24.height,
              ],
            ),
          ),
        );
      },
    );
  }
}
